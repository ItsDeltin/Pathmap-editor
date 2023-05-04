#Global variables

globalvar loadedMap_nodes
globalvar loadedMap_paths
globalvar loadedMap_attributes
globalvar loadedMap_globalAttributes
globalvar rayCast
globalvar dummies
globalvar foreachIndex
globalvar player
globalvar destination
globalvar attributes
globalvar closestNode
globalvar start
globalvar closestNode_0
globalvar goal
globalvar returnValue_aStar
globalvar open
globalvar cameFrom
globalvar gScore
globalvar current
globalvar path
globalvar neighbors
globalvar neighborIcons
globalvar foreachIndex_0
globalvar score


#Player variables

playervar pfUpdatePath
playervar pfDestination
playervar pfIsPathfinding
playervar pfCurrentNode
playervar pfAttributes
playervar pfPath


#Subroutine names

subroutine pathfindPlayer


rule "Pathfinder: Throttle to next node":
    @Event eachPlayer
    @Condition eventPlayer.pfUpdatePath == true
    
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.pfDestination if eventPlayer.pfCurrentNode == -1 else loadedMap_nodes[eventPlayer.pfCurrentNode]), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    eventPlayer.pfUpdatePath = false


rule "Pathfinder: Node reached":
    @Event eachPlayer
    @Condition eventPlayer.pfIsPathfinding == true
    @Condition (distance(eventPlayer, eventPlayer.pfDestination if eventPlayer.pfCurrentNode == -1 else loadedMap_nodes[eventPlayer.pfCurrentNode])) <= 0.4
    
    smallMessage(getAllPlayers(), "Node reached")
    if eventPlayer.pfCurrentNode == -1:
        eventPlayer.stopThrottleInDirection()
        #Stop pathfinding.
        eventPlayer.pfIsPathfinding = false
    else:
        eventPlayer.pfAttributes = [i.z for i in loadedMap_attributes if i.x == eventPlayer.pfCurrentNode and i.y == eventPlayer.pfPath.last()]
        eventPlayer.pfCurrentNode = eventPlayer.pfPath.last()
        del eventPlayer.pfPath[len(eventPlayer.pfPath) - 1]
    wait(0.2)
    if RULE_CONDITION:
        goto RULE_START


def pathfindPlayer():
    @Name "Subroutine: Pathfind Player"
    
    closestNode = (sorted(sorted(loadedMap_nodes, lambda player_: distance(player_, player.getPosition())).slice(0, 5), lambda i: not isInLoS(i + Vector.UP * 2, player.getPosition() + Vector.UP * 2, BarrierLos.PASS_THROUGH_BARRIERS)))[0]
    start = loadedMap_nodes.index(closestNode)
    closestNode_0 = (sorted(sorted(loadedMap_nodes, lambda player_: distance(player_, destination)).slice(0, 5), lambda i: not isInLoS(i + Vector.UP * 2, destination + Vector.UP * 2, BarrierLos.PASS_THROUGH_BARRIERS)))[0]
    goal = loadedMap_nodes.index(closestNode_0)
    open = [start]
    cameFrom = [-1 for player_ in loadedMap_nodes]
    gScore = [9999 for player_ in loadedMap_nodes]
    gScore[start] = 0
    while len(open):
        current = (sorted(open, lambda player_: gScore[player_] + distance(loadedMap_nodes[player_], loadedMap_nodes[goal]) * 2))[0]
        if current == goal:
            path = [-1]
            while current != -1:
                path.append(current)
                current = cameFrom[current]
            returnValue_aStar = path
            goto lbl_0
        neighbors = [i.y if i.x == current else i.x for i in loadedMap_paths if i.x == current or i.y == current]
        open.remove(current)
        neighborIcons = []
        for foreachIndex_0 in range(len(neighbors)):
            if all([player_.x != current or player_.y != neighbors[foreachIndex_0] or player_.z in attributes for player_ in loadedMap_attributes]):
                score = gScore[current] + distance(loadedMap_nodes[current], loadedMap_nodes[neighbors[foreachIndex_0]])
                if score < gScore[neighbors[foreachIndex_0]]:
                    cameFrom[neighbors[foreachIndex_0]] = current
                    gScore[neighbors[foreachIndex_0]] = score
                    if not neighbors[foreachIndex_0] in open:
                        open.append(neighbors[foreachIndex_0])
        wait()
    returnValue_aStar = []
    lbl_0:
    player.pfPath = returnValue_aStar
    player.pfDestination = destination
    player.pfIsPathfinding = true
    player.pfUpdatePath = true
    player.pfCurrentNode = player.pfPath.last()


rule "DEBUG: Pathfind dummy bots to cursor":
    @Condition hostPlayer.isHoldingButton(Button.MELEE) == true
    
    rayCast = raycast(hostPlayer.getEyePosition(), hostPlayer.getEyePosition() + hostPlayer.getFacingDirection() * 100, null, hostPlayer, false).getHitPosition()
    dummies = [player_ for player_ in getAllPlayers() if player_.isDummy()]
    destroyAllEffects()
    for foreachIndex in range(len(dummies)):
        player = dummies[foreachIndex]
        destination = rayCast
        attributes = [0, 1, 2, 3]
        pathfindPlayer()
        wait(3)


rule "DEBUG: Create dummy bot":
    @Condition hostPlayer.isHoldingButton(Button.INTERACT) == true
    
    createDummy(Hero.ASHE, Team.1, -1, raycast(hostPlayer.getEyePosition(), hostPlayer.getEyePosition() + hostPlayer.getFacingDirection() * 100, null, hostPlayer, false).getHitPosition(), Vector.LEFT - Vector.LEFT)


rule "DEBUG: Reset dummies":
    @Condition hostPlayer.isHoldingButton(Button.CROUCH) == true
    
    [player_ for player_ in getAllPlayers() if player_.isDummy()].teleport(hostPlayer)


rule "DEBUG: Host disable":
    @Condition hostPlayer.hasSpawned() == true
    
    hostPlayer.setPrimaryFireEnabled(false)
    hostPlayer.setMeleeEnabled(false)


rule "DEBUG: server load":
    hudSubtext(getAllPlayers(), "CAP: {0}, {1}, {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


