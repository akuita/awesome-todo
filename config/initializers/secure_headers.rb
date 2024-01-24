
# typed: false
# rubocop:disable Metrics/BlockLength
SecureHeaders::Configuration.default do |config|
  config.cookies = {
    secure: true, # mark all cookies as "Secure"
    httponly: true, # mark all cookies as "HttpOnly"
    samesite: {
      lax: true # mark all cookies as SameSite=lax
    }
  }
  # Add "; preload" and submit the site to hstspreload.org for best protection
  config.hsts = "max-age=#{1.week.to_i}"
  config.x_frame_options = 'DENY'
  config.x_content_type_options = 'nosniff'
  config.x_xss_protection = '1; mode=block'
  config.x_download_options = 'noopen'
  config.x_permitted_cross_domain_policies = 'none'
  config.referrer_policy = %w[origin-when-cross-origin strict-origin-when-cross-origin]
  config.csp = {
    default_src: %w[*],
    img_src: %w[* blob: data:],
    media_src: %w[* blob:],
    script_src: [
      "'self'",
      "'unsafe-inline'",
      'cdn.jsdelivr.net',
      'unpkg.com',
      'ga.jspm.io',
      'api.example.com', # Add your domain here
      'npmcdn.com',
      'code.jquery.com'
    ],
    style_src: [
      "'self'",
      "'unsafe-inline'",
      'fonts.googleapis.com',
      'api.example.com', # Add your domain here
      'cdnjs.cloudflare.com',
      'cdn.jsdelivr.net'
    ],
    # Ensure that CSP is also applied to password management integration endpoints
    form_action: [
      'api.example.com/password_management_integration'
    ]
  }
  # Add any other configurations here
end
# rubocop:enable Metrics/BlockLength
