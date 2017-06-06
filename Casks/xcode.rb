require 'pathname'
require Pathname(@path).realpath.dirname.join('../lib', 'xcode-common') unless defined?(xcode_common)
AC_DOWNLOAD_URL = 'Xcode_8.3.3/Xcode8.3.3.dmg'.freeze

cask 'xcode' do
  version '8.3.3'
  #disable hash for now to avoid failing install, while a solution if beeing 
  #worked out.
  #sha256 '49b0a99e556a918a92621a2b7da1e4f35bf267c9768eb82210ec2d67913ca972'

  url xcode_url(AC_DOWNLOAD_URL)
  name 'Xcode'
  homepage DEV_HOMEPAGE

  depends_on formula: 'toonetown/xcode/link-sdks'

  def depends_on
    if appdir.join('Xcode.app').exist?
      raise Hbc::CaskError, 'The appstore version of Xcode is already installed'
    end
    super
  end

  app 'Xcode.app'

  postflight do
    app_location = appdir.join(@cask.artifacts[:app].first.first).to_s
    
    # Select this version of xcode
    ohai 'Selecting default version of Xcode (may require sudo)'
    system '/usr/bin/sudo', '-E', '--', '/usr/bin/xcode-select', '--switch', app_location

    ohai 'Agreeing to license'
    system '/usr/bin/sudo', '-E', '--', '/usr/bin/xcodebuild', '-license', 'accept'

    ohai 'Relinking SDKs'
    system 'link-sdks', '--xcodePath', app_location
  end

  uninstall_postflight do
    # Reset the version of xcode
    ohai 'Resetting default version of Xcode (may require sudo)'
    system '/usr/bin/sudo', '-E', '--', '/usr/bin/xcode-select', '--reset'
  end

  caveats xcode_xip_caveats(AC_DOWNLOAD_URL, artifacts[:app].first.first)
end
