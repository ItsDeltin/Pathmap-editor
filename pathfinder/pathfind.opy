#Global variables

globalvar loadedMap_nodes 0
globalvar loadedMap_neighbors 1
globalvar rayCast 2
globalvar dummies 3
globalvar foreachIndex 4
globalvar player 5
globalvar destination 6
globalvar attributes 7
globalvar closestNode 8
globalvar start 9
globalvar closestNode_0 10
globalvar goal 11
globalvar returnValue_aStar 12
globalvar open 13
globalvar cameFrom 14
globalvar gScore 15
globalvar iter 16
globalvar current 17
globalvar path 18
globalvar foreachIndex_0 19
globalvar neighborI 20
globalvar score 21


#Player variables

playervar pfUpdatePath 0
playervar pfDestination 1
playervar pfIsPathfinding 2
playervar pfCurrentNode 3
playervar pfAttributes 4
playervar pfPath 5


#Subroutine names

subroutine pathfindPlayer 0


rule "Pathfinder: Throttle to next node":
    @Event eachPlayer
    @Condition eventPlayer.pfUpdatePath == true
    
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.pfDestination if eventPlayer.pfCurrentNode == -1 else loadedMap_nodes[eventPlayer.pfCurrentNode]), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    eventPlayer.pfUpdatePath = false


rule "Pathfinder: Node reached":
    @Event eachPlayer
    @Condition eventPlayer.pfIsPathfinding == true
    @Condition (distance(eventPlayer, eventPlayer.pfDestination if eventPlayer.pfCurrentNode == -1 else loadedMap_nodes[eventPlayer.pfCurrentNode])) <= 0.4
    
    if eventPlayer.pfCurrentNode == -1:
        eventPlayer.stopThrottleInDirection()
        #Stop pathfinding.
        eventPlayer.pfIsPathfinding = false
    else:
        eventPlayer.pfAttributes = (([i for i in loadedMap_neighbors[eventPlayer.pfCurrentNode] if i[0] == eventPlayer.pfPath.last()])[0]).last()
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
    iter = 0
    while len(open):
        current = (sorted(open, lambda player_: gScore[player_] + distance(loadedMap_nodes[player_], loadedMap_nodes[goal]) * 2))[0]
        #If the goal was found, reconstruct the path.
        if current == goal:
            smallMessage(getAllPlayers(), "Completed in {0} iterations".format(iter))
            path = [-1]
            while current != -1:
                path.append(current)
                current = cameFrom[current]
            returnValue_aStar = path
            goto lbl_0
        open.remove(current)
        for foreachIndex_0 in range(len(loadedMap_neighbors[current])):
            if all([i in attributes for i in loadedMap_neighbors[current][foreachIndex_0][1]]):
                neighborI = loadedMap_neighbors[current][foreachIndex_0][0]
                score = gScore[current] + distance(loadedMap_nodes[current], loadedMap_nodes[neighborI])
                if score < gScore[neighborI]:
                    cameFrom[neighborI] = current
                    gScore[neighborI] = score
                    if not neighborI in open:
                        open.append(neighborI)
        iter += 1
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
        wait()


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


