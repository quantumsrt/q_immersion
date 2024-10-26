# FiveM Immersion System

A comprehensive realism enhancement script for FiveM that improves gameplay immersion through various realistic mechanics and restrictions.

## Features

### Combat Enhancements
- **Combat Roll Restrictions**: Prevents unrealistic combat rolling while armed or shooting
- **Dynamic Reticle System**: Disables crosshairs for most weapons while retaining them for sniper rifles
- **Persistent Flashlight**: Maintains flashlight illumination while moving for better visibility

### Injury System
- **Leg Injury Mechanics**: Realistic leg injury effects when shot in the legs
- **Dynamic Movement**: Injured players experience movement impairment and occasional stumbling
- **Automatic Recovery**: Injuries heal after a configurable duration

### Vehicle Realism
- **Enhanced Vehicle Control**: Disables vehicle control when airborne or flipped
- **Vehicle Class Recognition**: Intelligently applies restrictions based on vehicle type
- **Exclusion System**: Certain vehicle types (aircraft, boats, motorcycles) maintain normal controls

### Additional Features
- **Prop Persistence**: Prevents props from falling off during impacts
- **Fully Configurable**: All features can be adjusted through the config file
- **Toggle Commands**: In-game commands to enable/disable features

## Installation
1. Place in your resources folder
2. Add to your server.cfg
3. Configure settings in config.lua

## Commands
- `/toggleflashlight`: Toggle persistent flashlight
- `/toggleproploss`: Toggle prop loss prevention
- `/toggleroll`: Toggle combat roll restrictions
- `/togglereticle`: Toggle reticle settings
- `/togglevehicle`: Toggle vehicle restrictions
