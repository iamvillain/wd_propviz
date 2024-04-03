Config = {}


Config = {
    Keybinds = {
        RotateLeft = 0xA65EBAB4, -- Left arrow key
        RotateRight = 0xDEB34313, -- Right arrow key
        Cancel = 0xB2F377E8, -- F key
        Place = 0x8FFC75D6 -- Left Shift key
    },
    MaxExistenceDistance = 50.0, -- prop deletes if exceeds and placement cancels
    DefaultMaxDistance = 5.0, -- how far until model deletes and comes back into view, also controls player distance from placement start
    PlacementModeText = "Left/Right Arrow: Rotate Object | F: Cancel Placement | Left Shift: Place Object"
}