# frozen_string_literal: true

module Igniter
  module Frontend
    module JavaScript
      module_function

      def runtime_source
        <<~JS
          (() => {
            if (window.IgniterFrontend) return;

            const registry = new Map();
            const instances = new WeakMap();
            let started = false;

            function dashize(value) {
              return String(value)
                .replace(/([a-z0-9])([A-Z])/g, "$1-$2")
                .replace(/_/g, "-")
                .toLowerCase();
            }

            function controllerNames(element) {
              return String(element.getAttribute("data-ig-controller") || "")
                .split(/\\s+/)
                .filter(Boolean);
            }

            function controllerAttribute(identifier, suffix) {
              return `data-ig-${identifier}-${suffix}`;
            }

            function coerceValue(raw) {
              if (raw === "true") return true;
              if (raw === "false") return false;
              if (raw === "null") return null;
              if (/^-?\\d+$/.test(raw)) return Number(raw);
              if (/^-?\\d+\\.\\d+$/.test(raw)) return Number(raw);
              if ((raw.startsWith("{") && raw.endsWith("}")) || (raw.startsWith("[") && raw.endsWith("]"))) {
                try {
                  return JSON.parse(raw);
                } catch (_error) {
                  return raw;
                }
              }

              return raw;
            }

            function escapeHtml(value) {
              return String(value).replace(/[&<>"']/g, (char) => (
                { "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;" }[char]
              ));
            }

            class Controller {
              constructor(element, identifier) {
                this.element = element;
                this.identifier = identifier;
              }

              connect() {}

              disconnect() {}

              targets(name) {
                const attr = controllerAttribute(this.identifier, "target");
                const targetName = dashize(name);
                return Array.from(this.element.querySelectorAll(`[${attr}~="${targetName}"]`));
              }

              target(name) {
                return this.targets(name)[0] || null;
              }

              hasTarget(name) {
                return this.target(name) !== null;
              }

              value(name, fallback = null) {
                const attr = controllerAttribute(this.identifier, `${dashize(name)}-value`);
                const raw = this.element.getAttribute(attr);
                return raw === null ? fallback : coerceValue(raw);
              }

              hasValue(name) {
                const attr = controllerAttribute(this.identifier, `${dashize(name)}-value`);
                return this.element.hasAttribute(attr);
              }

              dispatch(name, detail = {}) {
                this.element.dispatchEvent(new CustomEvent(`ig:${this.identifier}:${dashize(name)}`, {
                  bubbles: true,
                  detail
                }));
              }
            }

            class TabsController extends Controller {
              connect() {
                this.buttons = this.targets("button");
                this.panes = this.targets("pane");
                if (!this.buttons.length || !this.panes.length) return;

                this.handleButtonClick = this.handleButtonClick.bind(this);
                this.buttons.forEach((button) => {
                  button.addEventListener("click", this.handleButtonClick);
                });

                const initial = this.buttons.find((button) => button.getAttribute("aria-selected") === "true") || this.buttons[0];
                if (initial) this.activate(initial.getAttribute("data-ig-tabs-pane-id"));
              }

              disconnect() {
                if (!this.buttons || !this.handleButtonClick) return;

                this.buttons.forEach((button) => {
                  button.removeEventListener("click", this.handleButtonClick);
                });
              }

              handleButtonClick(event) {
                const button = event.currentTarget;
                this.activate(button.getAttribute("data-ig-tabs-pane-id"));
              }

              activate(targetId) {
                this.buttons.forEach((button) => {
                  const isActive = button.getAttribute("data-ig-tabs-pane-id") === targetId;
                  button.classList.toggle("active", isActive);
                  button.setAttribute("aria-selected", isActive ? "true" : "false");
                  button.setAttribute("tabindex", isActive ? "0" : "-1");
                });

                this.panes.forEach((pane) => {
                  pane.classList.toggle("active", pane.id === targetId);
                });
              }
            }

            function instanceStoreFor(element) {
              let store = instances.get(element);
              if (!store) {
                store = new Map();
                instances.set(element, store);
              }
              return store;
            }

            function connectElement(element) {
              controllerNames(element).forEach((identifier) => {
                const controllerClass = registry.get(identifier);
                if (!controllerClass) return;

                const store = instanceStoreFor(element);
                if (store.has(identifier)) return;

                const instance = new controllerClass(element, identifier);
                store.set(identifier, instance);
                if (typeof instance.connect === "function") instance.connect();
              });
            }

            function connectTree(root = document) {
              const elements = [];

              if (root.nodeType === 1 && root.hasAttribute("data-ig-controller")) elements.push(root);
              if (root.querySelectorAll) elements.push(...root.querySelectorAll("[data-ig-controller]"));

              elements.forEach(connectElement);
              started = true;
            }

            function connectIdentifierTree(root, identifier) {
              const elements = [];

              if (root.nodeType === 1 && controllerNames(root).includes(identifier)) elements.push(root);
              if (root.querySelectorAll) {
                root.querySelectorAll("[data-ig-controller]").forEach((element) => {
                  if (controllerNames(element).includes(identifier)) elements.push(element);
                });
              }

              elements.forEach(connectElement);
            }

            function register(identifier, controllerClass) {
              registry.set(identifier, controllerClass);
              if (started) connectIdentifierTree(document, identifier);
              return controllerClass;
            }

            register("tabs", TabsController);

            const api = {
              Controller,
              connect: connectTree,
              escapeHtml,
              register,
              start: connectTree
            };

            window.IgniterFrontend = api;

            if (document.readyState === "loading") {
              document.addEventListener("DOMContentLoaded", () => api.start(document), { once: true });
            } else {
              queueMicrotask(() => api.start(document));
            }
          })();
        JS
      end
    end
  end
end
