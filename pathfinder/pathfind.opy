#Global variables

globalvar pfLoadedmap_nodes
globalvar pfLoadedmap_neighbors
globalvar player
globalvar destination
globalvar attributes
globalvar start
globalvar goal
globalvar open
globalvar cameFrom
globalvar gScore
globalvar iter 
globalvar current 
globalvar neighbor 
globalvar neighborI 
globalvar score 


#Player variables

playervar pfDestination
playervar pfIsPathfinding
playervar pfCurrentNodeIndex
playervar pfWalkingToPosition
playervar pfAttributes
playervar pfPath


#Subroutine names

subroutine pathfindPlayer


rule "Pathfinder: Node reached":
    @Event eachPlayer
    @Condition eventPlayer.pfIsPathfinding == true
    @Condition distance(eventPlayer, eventPlayer.pfWalkingToPosition) <= 0.4
    
    #The player reached the next node in the path to the destination.
    #If pfCurrentNodeIndex is -1 then pfWalkingToPosition is the destination.
    if eventPlayer.pfCurrentNodeIndex == -1:
        #The destination was reached, stop pathfinding.
        eventPlayer.stopThrottleInDirection()
        eventPlayer.pfIsPathfinding = false
    else:
        #Update the current pathfind attributes.
        #Any rules watching these with the matching condition will activate.
        eventPlayer.pfAttributes = (([i for i in pfLoadedmap_neighbors[eventPlayer.pfCurrentNodeIndex] if i[0] == eventPlayer.pfPath.last()])[0]).last()
        #Go to the next node in the path.
        eventPlayer.pfCurrentNodeIndex = eventPlayer.pfPath.last()
        #Pop the current path.
        del eventPlayer.pfPath[len(eventPlayer.pfPath) - 1]
        #Set the position that the player is currently walking towards.
        eventPlayer.pfWalkingToPosition = eventPlayer.pfDestination if eventPlayer.pfCurrentNodeIndex == -1 else pfLoadedmap_nodes[eventPlayer.pfCurrentNodeIndex]
    wait(0.2)
    if RULE_CONDITION:
        goto RULE_START


def pathfindPlayer():
    @Name "Subroutine: Pathfind Player"
    
    start = pfLoadedmap_nodes.index((sorted(sorted(pfLoadedmap_nodes, lambda player_: distance(player_, player.getPosition())).slice(0, 5), lambda i: not isInLoS(i + Vector.UP * 2, player.getPosition() + Vector.UP * 2, BarrierLos.PASS_THROUGH_BARRIERS)))[0])
    goal = pfLoadedmap_nodes.index((sorted(sorted(pfLoadedmap_nodes, lambda player_: distance(player_, destination)).slice(0, 5), lambda i: not isInLoS(i + Vector.UP * 2, destination + Vector.UP * 2, BarrierLos.PASS_THROUGH_BARRIERS)))[0])
    open = [start]
    cameFrom = [-1 for player_ in pfLoadedmap_nodes]
    gScore = [9999 for player_ in pfLoadedmap_nodes]
    gScore[start] = 0
    iter = 0
    while len(open):
        current = (sorted(open, lambda player_: gScore[player_] + distance(pfLoadedmap_nodes[player_], pfLoadedmap_nodes[goal]) * 2))[0]
        #If the goal was found, reconstruct the path.
        if current == goal:
            smallMessage(getAllPlayers(), "Completed in {0} iterations".format(iter))
            player.pfPath = [-1]
            while current != -1:
                player.pfPath.append(current)
                current = cameFrom[current]
            goto lbl_0
        open.remove(current)
        for neighbor in range(len(pfLoadedmap_neighbors[current])):
            if all([i in attributes for i in pfLoadedmap_neighbors[current][neighbor][1]]):
                neighborI = pfLoadedmap_neighbors[current][neighbor][0]
                score = gScore[current] + distance(pfLoadedmap_nodes[current], pfLoadedmap_nodes[neighborI])
                if score < gScore[neighborI]:
                    cameFrom[neighborI] = current
                    gScore[neighborI] = score
                    if not neighborI in open:
                        open.append(neighborI)
        iter += 1
    lbl_0:
    player.pfDestination = destination
    player.pfIsPathfinding = true
    player.pfCurrentNodeIndex = player.pfPath.last()
    player.pfWalkingToPosition = pfLoadedmap_nodes[eventPlayer.pfCurrentNodeIndex]
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), player.pfWalkingToPosition), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)


