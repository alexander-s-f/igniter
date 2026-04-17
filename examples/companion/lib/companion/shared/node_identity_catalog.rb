# frozen_string_literal: true

module Companion
  module Shared
    module NodeIdentityCatalog
      module_function

      IDENTITIES = {
        "companion-seed" => {
          public_key: <<~PEM,
            -----BEGIN PUBLIC KEY-----
            MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvQ65u1dUxCVo3FEI57Ae
            vzsIDxE7cGvrYzXlWqBvzvVtNPsY13EyDn8I2hhlvRPxx1uOQF6CWxxDQEwLGNmq
            QW2OKkyMhJPBNg+pHMgNvm262EtAe+ElZ19D3729t8SLE7lz/jfLNCd0itFzLlgy
            9KtqF7IhN5osTKWJKwcgVfQwwpNRLu2mmtLxudt9+8wweORx2rDrH27kv4HLVMGl
            lF2tpWA7ztiOXnlUdTBjK8m5cGo6/HM7PMAFQvpzEbJrAvDtln852ZVwXuQWPx5G
            kGw17i9rb8GOJFCJXMa2J9I4nAI0ZO3pHYGfoBrKkvQ4DQEZx5Plkmh1V8l6YM0f
            XQIDAQAB
            -----END PUBLIC KEY-----
          PEM
          private_key: <<~PEM
            -----BEGIN RSA PRIVATE KEY-----
            MIIEowIBAAKCAQEAvQ65u1dUxCVo3FEI57AevzsIDxE7cGvrYzXlWqBvzvVtNPsY
            13EyDn8I2hhlvRPxx1uOQF6CWxxDQEwLGNmqQW2OKkyMhJPBNg+pHMgNvm262EtA
            e+ElZ19D3729t8SLE7lz/jfLNCd0itFzLlgy9KtqF7IhN5osTKWJKwcgVfQwwpNR
            Lu2mmtLxudt9+8wweORx2rDrH27kv4HLVMGllF2tpWA7ztiOXnlUdTBjK8m5cGo6
            /HM7PMAFQvpzEbJrAvDtln852ZVwXuQWPx5GkGw17i9rb8GOJFCJXMa2J9I4nAI0
            ZO3pHYGfoBrKkvQ4DQEZx5Plkmh1V8l6YM0fXQIDAQABAoIBADdSHMUV++bdb36w
            c6OgJI8ejfAiwbrWyW0hczh+o9jydf8/zngUVmppf8SZyQN315LXVpu9S/WvInqp
            BcJCxxAYJ7Z26dNNjQbttDWI0IS9hSQPeRIGwrQp6ymIUwB4EZ428RsdZmefd/m6
            6jJQerCfjA7c/91OTtIqyiV+E1cy+KnMcZc0Z2ZrN+LorWuzTM+/aZEm90tj6g3a
            SyrL/FCd4b0dHOp/zCagcnL03VCffXILZDSFJPN51h+NV/hJsmw9kz7UCIgQ104h
            RRJavCpVdv6D3/NpgkRNDsFir04QqE2Fv6hTnmu7Ujis5bnxVbWIia8HYrP4p3oQ
            NwP5mZ0CgYEA9MUlgwzSIjdGmWpFsJzFjfPllzH95oirWBqgtiFBirl/FbuBoBve
            BiR7RltmD4XIZ7kXLwq0r+9f/3RGcEb3tg3zBo96jnvvST8waKWie/6TJ98N1RO1
            pQrGuZGwa7SMxXlvL/H38DDfE9n1/cnXms7uCpTw561YlDe/ehjhxN8CgYEAxbs6
            ayBAg24ZaqNHJMOhUepoSGxF69kNx3AGTOuIO6+ui2Druu2qhV02mhAidJMhvmmb
            V+BfRu6cbwj0ET2lDuD+mn2HooOOX2sXV2vbr5b+BzYPQKPELPGNgjpSNOvQ8f3E
            /q5f/v5dxVmEyiGXHL5fG4nR+Ly3MaAXBAC7h0MCgYEA3b24FPfJafvfdl5DEhOE
            GOxKIuXEGVPYvfEphLWt9anESoDalpyIT9I+52cnl4pgGi8gpJozRGs78WV55n80
            K3aJonja0zfNd/LJvRPIlkHzOBynIFBBr2mKzFQCmiAvozo2kx3Guo7bmNVNN4Pi
            UbmDBo0VjRyJ8YRrb4YZCcsCgYBqcW/xW1tfZVWpYlxaHjYpstaQpji9zgrs4hGC
            NwkPmHON9I7yAh9Zy+Qo66agutPffVpy5AZmWO09mMRKw7SnXdexswHhKpDqLOxT
            02xgChiWKTPsyDxDNYXIJT073/aLTuFNePGUg7pXEum5JnwCrTjlyjuOe4ji3huF
            vB83oQKBgEQSZLI0ftfpT+bnFrdGbTDgSCcvr13Jx/Hi0xGmRPFnt7LYrLiHJWyW
            pWFRslmud6Dch3jO7uEOwBFdm/ItWwxvAT9xjDFMId3nlh7DvT6MV94LfTWAXtBZ
            GKmBpk9jL9LCwTqoqX0+o1VSjw0LiXh6tXvaLYEzsZKCzPb1tP6p
            -----END RSA PRIVATE KEY-----
          PEM
        },
        "companion-edge" => {
          public_key: <<~PEM,
            -----BEGIN PUBLIC KEY-----
            MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6xiL/UOYmDUp4G6Ty12A
            H8/TA/cS0fGy06VmiZA8UFbpYbfY8hRBgLaTQGBQr9+V4KpEhv6AE7oFurKnW7KZ
            NQeIm8zoEeAFeW4IxduhGayEMppc8/VPKtffyir0e8A1ziJGgjDqePWS/GBBQlPk
            yxO6yhSDbV+H6WK1ly8YjLd2NOtRLXS389DfPMD7XWBi/Pmpm+Ky3cqUfth8Ej9e
            0Jsvewl60OUB5Cn6c6Yb6ZzNAh350SGhs+qOGumQid77O15IyQaCIbTY+f4TQxFd
            eC2+nqeMN1FmyuCiRjuQoqFeMT8B7ory9NL7Kc+8ZyH94Xbm0wwB8XbZDFctqIVo
            uwIDAQAB
            -----END PUBLIC KEY-----
          PEM
          private_key: <<~PEM
            -----BEGIN RSA PRIVATE KEY-----
            MIIEowIBAAKCAQEA6xiL/UOYmDUp4G6Ty12AH8/TA/cS0fGy06VmiZA8UFbpYbfY
            8hRBgLaTQGBQr9+V4KpEhv6AE7oFurKnW7KZNQeIm8zoEeAFeW4IxduhGayEMppc
            8/VPKtffyir0e8A1ziJGgjDqePWS/GBBQlPkyxO6yhSDbV+H6WK1ly8YjLd2NOtR
            LXS389DfPMD7XWBi/Pmpm+Ky3cqUfth8Ej9e0Jsvewl60OUB5Cn6c6Yb6ZzNAh35
            0SGhs+qOGumQid77O15IyQaCIbTY+f4TQxFdeC2+nqeMN1FmyuCiRjuQoqFeMT8B
            7ory9NL7Kc+8ZyH94Xbm0wwB8XbZDFctqIVouwIDAQABAoIBACTXs3SMx9iumDH2
            Uk4QCJizqoeYDEh/fr1hUdjkFDeo7ykjtSl22C8SLbBsh6iQOv464MNhFfRBdk1k
            WwrpSc5AMH3uFj5a47C8eD59pVkPKqZ9f2yx+Gan7wfRRIAyRpxXzcHwZYZwQckw
            UnnRCO10WZT6swAMdRGzqO6Y8Fl4x/SxhkyxFAQrCuOr2QQ3+dvUOlWuuQNlf/C7
            194E0+1wA3A45MnYOQXyGeaB6sQ6ZKvkCmL/IG0rPcXu8FfZAde01ySPQ+S99eQ+
            2VUdUciHPEz1XVU3cf2E6KHBYRwihdm3RMyynKL2b4NB3JaO6yamtOd5v8wOhJB0
            AQJzA90CgYEA+L+TLST4fROWLN88kt81bSP/ccs7MchL0eATOBYJycU0VfJwCpIn
            5qmS/wjm0gpCtwWY81s2pcCtvmuapPlBocqpQLRPh70xOaTfiMw9/B6Gsj2ywF4W
            UbQYLeRynrNq8XdhgmfXWouijkxHKjbYO5lyKckhx+7YMWTIV83udQ8CgYEA8fMV
            MLo4sD7CPdgyJgOiCo2jHGLxMT5pFDJGLdeTd2a0zuJpO1WO1cGvLSdT3Trc4uTc
            G+IlLN8+LwJORxXL9K9drtlkzI3R3GufCy6DJZUAEzDrkQWRGJRZW1PWtRpOUQCt
            JEx6KHerUoOXjicT8GE41PaBpM86Odt20gEGSZUCgYAFVx+SxYtsLAJ6XiSPxqj/
            +djfGYzgybsO+2+OMbLuGQTBn53WLEMdCaD1Rryl38CE62LYPqoSrutL/kVoq01E
            avRtRjG66U3oPejqp+/gvMsJgpeW165E/MfUHGZ1j8aI/pYiVZZjBEJuKacRefH0
            fZvc18uY3kDX9qDyeaJX8wKBgEJDnhEbX309ovtHI+zvX8jeI8cZfg9LlYHXhwr1
            GMlB0tE6hzGd7CG1CyIlvD1B6s8lePcWB7Jzbdd4HTIw0Qwxn0nM9mNjkA97VjK8
            yWRYm42l/05XpPaDYrm1i39MNhjPQ5xGacp9g+l0auSe5UIXjnYdEUKvErZX2gII
            D83FAoGBAK1AlSECpV259GtymlLPkM/p4O0mwoWKd49bUHmnRf4dm05XSXFc7O79
            dg3OAapK1zGVUcff4Icg+EqzNJGasFgGTmRnxxfyGFOJVdH8YylDJxQPbDYHEspM
            npKgBeftPebu6ngInhpH5NBwZ1W0g+A/19njITqllwPVZprdVjP5
            -----END RSA PRIVATE KEY-----
          PEM
        },
        "companion-analyst" => {
          public_key: <<~PEM,
            -----BEGIN PUBLIC KEY-----
            MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjhXyt1g5HdEK0iwUjW1k
            2P29lg7BAGuUQ1Bf+uSnXg1+kmalT288XxX2dawdL4yHRotZYHwPEZEEZ1sM1icD
            dx2LbiMnYSW4NCp8bXMRYz5jWZZdOrQfQP2WJAejs+cm9RwNylHXyfjXJ38uHgbW
            z28pE2e8C2fDXy+msomCXGqALDns6DtpagpHWNTC/GASyvUa365un9gHY4hZr2rt
            f96E+mJypZ99OXNPdaiXWgt8ULG9KzxjfTDlKXHH4XSS5lxlD7N0GGlGrufCnp/C
            oyGH/36MZzfSKP5E3qHNsnZ7EFHvYpzoIGuv21zVy32u8GrjCPCjz0xBEaRkkg9e
            iQIDAQAB
            -----END PUBLIC KEY-----
          PEM
          private_key: <<~PEM
            -----BEGIN RSA PRIVATE KEY-----
            MIIEowIBAAKCAQEAjhXyt1g5HdEK0iwUjW1k2P29lg7BAGuUQ1Bf+uSnXg1+kmal
            T288XxX2dawdL4yHRotZYHwPEZEEZ1sM1icDdx2LbiMnYSW4NCp8bXMRYz5jWZZd
            OrQfQP2WJAejs+cm9RwNylHXyfjXJ38uHgbWz28pE2e8C2fDXy+msomCXGqALDns
            6DtpagpHWNTC/GASyvUa365un9gHY4hZr2rtf96E+mJypZ99OXNPdaiXWgt8ULG9
            KzxjfTDlKXHH4XSS5lxlD7N0GGlGrufCnp/CoyGH/36MZzfSKP5E3qHNsnZ7EFHv
            YpzoIGuv21zVy32u8GrjCPCjz0xBEaRkkg9eiQIDAQABAoIBAAZ9pHBBfp948515
            D8nLrewXQFxM6X51S6k9EFtn62jppSb3OzVLI7cEy/Thc1ZfHTVo64DzveT7qte1
            YjtcviTog7x47OU8WcNBTxyZYXmXCacXrkPeo2BezUdxVWZEKKSRHuSnkzvp6xtF
            7TOINLM2dOoK5r1fJL7SEJOOolbKIcbrur/FDZcXUshDfZXePSVGz5KUVryru9wJ
            vh4WANIp8ZTprX9bBcW//g89N/VRXgXy4PjY5UiswCK1vuQc1JZAfH0g0FNJrLtY
            FfuYZlP95rzKsxZzlxGb6Qt2qeXaKklWxZ76CPllqUemQGB35fwOmdA6qTAHreZA
            FgqjWhECgYEAxr87Beba8CmpZj6aHrxGsKaFlfuL94duBS6EHrVG8t1kPePamicF
            IROJlOv46Rdg9m07f4ixBKw/sXM775t59Mp5cr49tkbf0ZctSvKNA71s45AcgvvI
            csNuqk6+8TKszIaxG9Q3Hpf4cJLvkG5SQGWVi9IPNWm9ZfOTSln6W/kCgYEAtwQv
            D5Q1+j0Py+vOmAjrN/bXndN6lgxkXM0E/JTpBMOGc8c155rvuolFnM3VamKpNhJq
            AlvPAbEpkWOZNQIT00xqq3cRd0782/050HIpj7z+tGMeMlKBRi0d6GgLBOZ6OO6L
            P/AIx7uCGYljiBAM0DT0aZo4uzLUxn6jd42cGxECgYEAhW8eUXgMxfEyqlKdZsVB
            MJicV3XrIuTqGNCCI5vRZnz9MBAqVBSefPaBCFrlYpkvoEL2D0nWjyyWFq0nMFdS
            KedGYqMXC6nJ2w2Eey0dP8WNtbqracVhbquHQRBdYdKD8Uz825I+72tYgTwlWvK2
            hkWtgZImY9X6Mti1qtV+IQECgYBXQalmVhV+H0q+wMiY9/edkRSv7LoPfA0FqcHs
            4tpOKSKbZKkwqVAOsY/8+K39sNhYLWNZiIgjmGHnLYNIIJtvLInXAkfTiFdKU2sT
            FLr4CvWs72zgNTHpUW1m9uP6DCDNr/24GCs3fxDCOBy6LFzPj8/P4XWW2t9TW+F4
            CI4a4QKBgH9kZ1SHhgu6q3m88CiwQOsE+tvCbCJKTYPq1LCHoN/RrYIDCGiAVqB/
            TR+5QLjkQkvvI8/+tvmhYo4m3tdOZs3/CiPXNK3a+hUEnYo6ltEenQTx4R1WVNvA
            ujgdjstkwsr7+XQAqvmZxsIbP3PodcF7m90mLu5ByOQSQbVXRJxT
            -----END RSA PRIVATE KEY-----
          PEM
        }
      }.freeze

      def identity_for(node_name)
        source = IDENTITIES.fetch(node_name.to_s)
        Igniter::Cluster::Identity::NodeIdentity.new(
          node_id: node_name.to_s,
          public_key_pem: source.fetch(:public_key),
          private_key_pem: source.fetch(:private_key)
        )
      end

      def trust_store
        entries = IDENTITIES.map do |node_name, keys|
          {
            node_id: node_name,
            public_key: keys.fetch(:public_key),
            label: "companion-local"
          }
        end
        Igniter::Cluster::Trust::TrustStore.new(entries)
      end
    end
  end
end
