# Mini Don't Starve Together Environment Simulator

## Introduction

This is to port DST global environment to DS. The functions lacking in DS are either patched or redirected to null operation. So that DST scripts can run without crash in this environment.

But there are things not possible in DS, such as some C/C++ level functions regarding animation. I cannot do anything for these. Another important thing is that `entity` is excluded from the patch work, meaning you must manually delete `entity:AddNetwork` and `entity:SetPristine`, though this can be done automatically.

I only ported a limited subset of DST env for my own use.

## File description

### Action

```lua
DSTAction = Class(Action,
    function(self, data, instant, rmb, distance, ghost_valid, ghost_exclusive, canforce, rangecheckfn, crosseswaterboundary, overrides_direct_walk)
    end
)
```

`AddAction` remains the same. But `AddComponentAction` is connected to DS API.

### AnimState

Some functions are impossible.

The `GetXXX` functions are implemented via a table that records AnimState to build relation. But to maintain this table a garbage collecting routine is a must.

The skin functions are redirected to simple no skin functions because DS doesn't support skins. So I think for the sake of performance it is better not to validate build against bank.

### Asset

Same as DS.

### Containers

Hacked to show item tile background, you need to modify accordingly. You can add your container widget by `require`.

### EntityScript

Many functions are missing and related to components.

### Globals

A collections of constants.lua, util.lua, etc..

### Inventory

Almost full implement of `TheInventory` and `InventoryProxy`

### InventoryItemAtlas

Full implement of `RegisterInventoryItemAtlas`

### Netvar

Full implement of net variables, but type-insensitive.

### NetworkingRPC

Empty implement of RPC. You should not use any RPC call in server.

### Physics

Only `Launch` is needed so only this one.

### 