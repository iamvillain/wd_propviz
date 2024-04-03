
# wd_propviz

A tool to help visualize prop placement for different RedM scripts. Native support for RSG, easy to convert.

WIP


## Usage/Examples

```lua
Pass the model name and max distance, eg:
local modelName = "p_cottonbox01x"
local maxDistance = 10.0

or place them directly in the export.

local coords, rotation = exports.wd_propviz:visualizePlacement(modelName, maxDistance)

    if coords and rotation then
        print(string.format('Object placed at coordinates: vector3(%f, %f, %f)', coords.x, coords.y, coords.z))
        print(string.format('Object rotation: %f, %f, %f', rotation.x, rotation.y, rotation.z))
    else
        print("Object placement cancelled or failed")
    end
```

