# Pathmap editor

Import code: `hp2dg`

A stable, fast, dynamic, and easy to use pathfinding system that you can add to your gamemode.
Support for [vanilla workshop syntax](https://workshop.codes/wiki), [OSTW](https://github.com/ItsDeltin/Overwatch-Script-To-Workshop), and [OverPy](https://github.com/Zezombye/overpy).

<https://ko-fi.com/deltin>

Note: This is not like other tools where you import the code in Overwatch, copy the rules, then paste it into your gamemode. The editor will *generate* workshop code which can be copy and pasted from the log in the inspector.

To get started, import the code, open the menu by pressing \[**Interact**] and then click **Guide**.

Thanks to Josbird for [cursor menu](https://workshop.codes/GETVX) and [noclip](https://workshop.codes/50RQ1), and Zezombye for the map mirror data.

## Features

- No external application required. Code generation for all 3 target languages, saving+loading can all be done from within Overwatch.
- Bots can be added to test your map inside the editor.
- Attributes can be used to create advanced paths, such as:
  1. Transverse paths using hero abilities.
  2. Melee fences and jump over obstacles.
  3. Gates that are only open when the payload reaches a checkpoint.
  4. Restrict spawn rooms to teams.
- An in-game rule creator to generate workshop code related to pathfinding.
- Symmetrical Overwatch maps can be mirrored.
- The pathfinder is extremely easy to control, simply set a player's `pfDestination` variable to a location and the bot will start moving.
  - This also makes it easy to make a bot chase a player; just chase the `pfDestination` variable to the player's position!
- Stable, no server overload even with 23 bots chasing a moving target on the largest map in the game.

## The basics

### Editor

Click on the world to create a node. Clicking on the node will allow you to create a path connecting the nodes to each other. Pathfinders will navigate between each of the connected nodes.

### Attributes

A path between 2 nodes can have any number of attributes. Attributes are unidirectional, which means that you can have a different set of attributes depending on the direction the bot is walking. If a path has an attribute, the bot's `pfPlayerAttributes` player variable must contain *at least one* of the path's attributes in order for the path to be valid.

I recommend writing down the purpose of each of the attribute values in your map, for example: `1` is for paths that require a jump, or `2` is for paths that have a fence that needs to be punched.

It can be difficult at first to organize your attributes and assign them to different functions. This is the strategy that I find to be the best:

Find every path in your map that can't be transversed with a hero that doesn't have any movement abilities. Tag those paths with a dummy attribute, such as `-1`. Add more attributes on top of it for hero abilities, such as `3` for heroes that have medium-distance leaping abilities (D.Va, Winston, Widowmaker, Pharah, Genji, etc.) `4` for Hanzo and Genji's wall climb, `5` for paths that Ashe can jump with her shotgun, and so on.

When assigning the attributes to heroes (`pfPlayerAttributes`), no one is allowed to use the `-1` attribute. When moving a Hanzo dummy bot, the pathfinder will ignore paths with attributes `[-1, 3]` because Hanzo isn't allowed to use either, but will cross paths with `[-1, 4]` because Hanzo is allowed to cross paths with `4`. `[-1]` paths are ignored by everybody.

## Preloaded maps

These workshop codes contain the editor loaded with a map. You can use these in your gamemode or as an example for what your map should look like. If you create a new map, send me the import code and I will add it to the list.

| Map           | Import code | Editor version |
| ------------ | ------------- |-----------------|
| Esperança  | GZWF9         | v1.0.0              |
| Hanamura  | FQY78          | v1.0.0              |

To create your own import code, follow the guide in **How to save & load** then click **Share Code** in Overwatch.

## How to save & load

- Saving

 1. Turn on the `Enable Workshop Inspector Log File` setting in `Gameplay > General`.
 2. Open the inspector
 3. Click the `(X)` button and save the copied contents into a file.

- Loading
  1. Paste the saved contents into the first workshop rule.
  ![](https://cdn.workshop.codes/ysdg9njdg62z0zajemhgryvxuhaw)

## How to use exported code

When the `pfDestination` player variable is set, the player will pathfind to that position. If you want the dummy to follow a player, you can chase the variable to that player's position.

Example:
There is a player variable named `chaseTarget` which is the player that the bot is chasing.

- Workshop: `Chase Player Variable At Rate(Event Player, pfDestination, Position Of(Event Player.chaseTarget), 100, Destination And Rate);`
- OSTW: `ChaseVariableAtRate(pfDestination, PositionOf(chaseTarget), 100, RateChaseReevaluation.DestinationAndRate);`
- OverPy: `chase(eventPlayer.pfDestination, hostPlayer.getPosition(), rate=100, ChaseReeval.DESTINATION_AND_RATE)`

### How to use attributes

The examples here will be shown using OSTW syntax but will work for the workshop and overpy.

#### Spawn rooms

To prevent players from walking into the enemies spawn room, you can tag the paths leading into the rooms with `1` for Team 1 or `2` for Team 2.

```
rule: 'Pathfinder: Team 1 attributes'
Event.OngoingPlayer
Team.Team1
{
    pfPlayerAttributes.ModAppend([1]);
}

rule: 'Pathfinder: Team 2 attributes'
Event.OngoingPlayer
Team.Team2
{
    pfPlayerAttributes.ModAppend([2]);
}
```

#### Hero abilities

When you have paths that certain heroes can cross using their abilities, you will need to set their attributes at the start of the game so that the pathfinder can recognize that they are allowed to cross these paths.

Lets assume that paths with an attribute of `3` are for heroes that can climb walls, and paths with an attribute of `4` are only for heroes that can double jump.

```
rule: 'Pathfinder: Genji Attributes'
Event.OngoingPlayer
Player.Genji
{
    pfPlayerAttributes.ModAppend([3, 4]);
}

rule: 'Pathfinder: Hanzo Attributes'
Event.OngoingPlayer
Player.Hanzo
{
    pfPlayerAttributes.ModAppend([3]);
}
```

## Cleaning up your save

There is a chance that Overwatch will not accept your save. There are two main reasons why this may happen.

1. When new versions of the editor are released, the new global variable set might differ from the global variables in the save.
2. Extraneous data in the save that is not needed makes the workshop too large.

Both of these issues can be fixed by cleaning up your save file.

Step 1: Delete the `variables { ... }` section.
Step 2: Delete variable assignments not in this list:

- __loadPersist
- version
- map
- NodeUniqueID
- SegmentUniqueID
- AttributeUniqueID
- Nodes\_Node_UniqueID
- Nodes\_Node_Position
- Segments_ID
- Segments_Node1
- Segments_Node2
- Attributes_Value
- Attributes_ID
- Attributes_Node1
- Attributes_Node2
- savedPlayerLocation
- savedPlayerDirection
- IsNoclipping
- Rules\_Actions_Data*
- Rules_ExecutesOnAttribute*
- Rules_EnabledHeroes*

\* These variables contain the data for the rules that you have created. If you want to transfer your custom rules to another map, you can copy these variables over.
