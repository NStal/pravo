# Core APIs

* Session
  * Sign up
    POST /me/register {email,password}
  * Sign in
    POST /me/session {email,password}
  * Sign out
    DELETE /me/session
    
* Sync (Device/Wallpaper)
  * Get devices to see if this device has already registered
    GET /devices
  * Create device with no physical device related (user create)
    POST /devices {device}
  * Create device with physical device related (auto create)
    POST /devices {device with deviceGuid}
  * Set device wallpaper
    PUT /devices/:device_id/wallpaper   {wallpaper}
    
    
* Gallery
  * Get artworks to display
    GET /artworks
  

# User flow

Signin -> Sync device/wallpaper -> Show artworks |
|-> Choose a artwork -> Cut a artwork -> Save to device |
|-> Apply wallpaper if it's the current device.
