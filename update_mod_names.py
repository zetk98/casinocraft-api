import json

# Load current mods.json
with open('mods.json', 'r') as f:
    data = json.load(f)

# Mod name mapping
mod_names = {
    'sodium': 'Sodium',
    'lithium': 'Lithium',
    'iris': 'Iris',
    'xaerominimap': 'Xaero Minimap',
    'xaeroworldmap': 'Xaero World Map',
    'sodium-fabric': 'Sodium',
    'lithium-fabric': 'Lithium',
    'iris-fabric': 'Iris',
    'roughlyenoughitems': 'REI',
    'modmenu': 'Mod Menu',
    'fabric-api': 'Fabric API',
    'farmersdelight': "Farmer's Delight",
    'storagedelight': 'Storage Delight',
    'moredelight': 'More Delight',
    'display-delight': 'Display Delight',
    'display_delight': 'Display Delight',
    'ecologics': 'Ecologics',
    'terralith': 'Terralith',
    'dungeons-and-taverns': 'Dungeons and Taverns',
    'mcw-furniture': 'MCW Furniture',
    'mcw_furniture': 'MCW Furniture',
    'entityculling': 'Entity Culling',
    'ferritecore': 'Ferrite Core',
    'travelersbackpack': "Traveler's Backpack",
    'waystones': 'Waystones',
    'trinkets': 'Trinkets',
    'friendsandfoes': 'Friends and Foes',
    'cardinal-components-api': 'Cardinal Components API',
    'architectury': 'Architectury',
    'balm': 'BALM',
    'jamlib': 'JamLib',
    'forgeconfigapiport': 'ForgeConfigAPI Port',
    'resourcefullib': 'Resourceful Lib',
    'placeholder-api': 'Placeholder API',
    'yet_another_config_lib': 'YACL',
    'essential_commands': 'Essential Commands',
    'fallingtree': 'Falling Tree',
    'niftycarts': 'Nifty Carts',
    'sort_it_out': 'Sort It Out',
    'status-effect-bars': 'Status Effect Bars',
    'entity_texture_features': 'Entity Texture Features',
    'jade': 'Jade'
}

# Update required mods
for mod in data['requiredMods']:
    mod_id = mod['id'].lower()

    if 'casinocraft' in mod_id:
        mod['name'] = 'ZetDeyNeCraft'
        mod['version'] = '1.5.0'
    elif 'fabric-api' in mod_id:
        mod['name'] = 'Fabric API'
        mod['version'] = '0.141.3'
    else:
        mod['name'] = mod['id'].split('-')[0]

# Update optional mods
for mod in data['optionalMods']:
    mod_id = mod['id'].lower()

    # Find matching name
    for key, value in mod_names.items():
        if key in mod_id:
            mod['name'] = value
            break
    else:
        # Use first part of id as name
        mod['name'] = mod['id'].split('-')[0]

# Write back
with open('mods.json', 'w') as f:
    json.dump(data, f, indent=2)

print(f'Updated {len(data["requiredMods"])} required mods')
print(f'Updated {len(data["optionalMods"])} optional mods')
print('\nRequired Mods:')
for mod in data['requiredMods']:
    print(f"  - {mod['name']} v{mod['version']}")
