# Web Permission Testing Guide

## Overview
This guide explains how to properly test browser permissions for the permission_master plugin in web environments.

## Prerequisites

### HTTPS Context Required
Browser permissions (camera, microphone, location, notifications) **require HTTPS** context or `localhost` for security reasons.

### Testing Options

#### Option 1: Local Development (Recommended)
```bash
# Serve the example app over HTTPS or localhost
flutter run -d chrome --web-port 8080 --web-hostname localhost
```

#### Option 2: HTTPS Local Server
```bash
# Build the web app
flutter build web

# Serve with HTTPS (using tools like serve, http-server, etc.)
# Example with serve:
npx serve build/web --ssl
```

#### Option 3: ngrok for External Testing
```bash
# After building web app
flutter build web

# Serve locally
npx serve build/web

# In another terminal, expose via ngrok
ngrok http 3000
```

## Browser Permission Setup

### Chrome
1. Open Chrome Settings → Privacy and Security → Site Settings
2. Configure permissions for:
   - **Camera**: Allow for your domain
   - **Microphone**: Allow for your domain
   - **Location**: Allow for your domain
   - **Notifications**: Allow for your domain

### Firefox
1. Open Firefox Settings → Privacy & Security → Permissions
2. Configure site-specific permissions

### Safari
1. Safari → Preferences → Websites
2. Configure permissions per website

## Common Issues and Solutions

### Error: "Permission denied"
**Cause**: Browser security restrictions or user denied permission
**Solution**: 
- Ensure HTTPS/localhost context
- Check browser settings
- Look for permission prompts

### Error: "Permission not supported"
**Cause**: Missing hardware or browser support
**Solution**:
- Verify hardware availability
- Check browser compatibility
- Test on different browser

### Error: "HTTPS required"
**Cause**: Testing on HTTP instead of HTTPS
**Solution**: Use localhost or set up HTTPS server

### Chrome Specific Issues
- **Insecure origins**: Use `chrome://flags/#unsafely-treat-insecure-origin-as-secure`
- **Local testing**: Use `http://localhost` (exempt from HTTPS requirement)

## Testing Checklist

- [ ] Running on HTTPS or localhost
- [ ] Browser permissions configured
- [ ] Hardware available (camera, microphone)
- [ ] Location services enabled (for geolocation)
- [ ] Browser console checked for errors

## Debugging Tips

### Check Browser Console
Open Developer Tools (F12) and check:
- Console for JavaScript errors
- Network tab for HTTPS status
- Application tab for permission settings

### Permission States
- **granted**: Permission already granted
- **denied**: Permission denied by user
- **prompt**: Permission not yet requested
- **error**: Technical error occurred

### Testing Commands
```javascript
// Check permission status in browser console
navigator.permissions.query({name: 'camera'}).then(result => console.log(result.state));
navigator.permissions.query({name: 'microphone'}).then(result => console.log(result.state));
navigator.permissions.query({name: 'geolocation'}).then(result => console.log(result.state));
navigator.permissions.query({name: 'notifications'}).then(result => console.log(result.state));
```

## Production Deployment

When deploying to production:
1. Ensure HTTPS is properly configured
2. Add proper Content Security Policy headers
3. Configure CORS if needed
4. Test on target browsers

## Browser Compatibility

| Browser | Camera | Microphone | Location | Notifications |
|---------|--------|------------|----------|-----------------|
| Chrome  | ✅     | ✅         | ✅       | ✅              |
| Firefox | ✅     | ✅         | ✅       | ✅              |
| Safari  | ✅     | ✅         | ✅       | ✅              |
| Edge    | ✅     | ✅         | ✅       | ✅              |

*Note: All require HTTPS except localhost*