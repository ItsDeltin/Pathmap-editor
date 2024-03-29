#Global variables

globalvar pfLoadedMap_nodes
globalvar pfLoadedMap_neighbors
globalvar pfIterationsThisTick
globalvar pfExecOwner
globalvar i


#Player variables

playervar pfWait
playervar pfDestination
playervar pfPlayerAttributes
playervar pfAttributes
playervar pfSavedTarget
playervar pfIsPathfinding
playervar pfCurrentNodeIndex
playervar pfWalkingToPosition
playervar pfPath
playervar pfStartTime
playervar pfWalkingFromPosition
playervar pfActiveNode
playervar pfStuckOnNode
playervar pfWasBroadcasted
playervar pfIsStuck
playervar goal
playervar scores_gScore
playervar scores_fScore
playervar scores_parent
playervar scores_nodeIndex
playervar open
playervar checkedNode
playervar iter
playervar current
playervar currentInExistingPath
playervar broadcastTo
playervar neighbor
playervar neighborI
playervar scoreIndex
playervar score


#Subroutine names

subroutine pfTick
subroutine pfUpdateNodeMeta
subroutine pfWalkToDestination
subroutine pfProgressEventPlayer
subroutine pfRecalibrate
subroutine pfLookAtDestination


rule "【PF Core】Prepare loaded map":
    waitUntil(pfLoadedMap_nodes, 9999)
    for i in range(len(pfLoadedMap_nodes)):
        pfLoadedMap_nodes[i] = vect(pfLoadedMap_nodes[i].x, floor(pfLoadedMap_nodes[i].y) + (i / 1000 * (-1 if pfLoadedMap_nodes[i].y < 0 else 1)), pfLoadedMap_nodes[i].z)


rule "【PF Core】Select next pathfinder":
    @Condition (not entityExists(pfExecOwner) or pfExecOwner == null) == true
    @Condition any([player.pfWait for player in getAllPlayers()]) == true
    
    pfExecOwner = sorted([player for player in getAllPlayers() if player.pfWait], lambda i_: i_.pfWait)[0]
    wait()
    if RULE_CONDITION:
        goto RULE_START


def pfTick():
    @Name "【PF Core Subroutine】☞ Tick"
    
    pfIterationsThisTick -= 1
    if pfIterationsThisTick <= 0:
        wait()
        waitUntil(max(getAverageServerLoad(), getServerLoad()) < 255, 0.25)
        #This determines the pathfinding budget for the current tick.
        pfIterationsThisTick = ((max(getAverageServerLoad(), getServerLoad()) < 230) + ((max(getAverageServerLoad(), getServerLoad()) < 180) * 2)) + 1


def pfUpdateNodeMeta():
    @Name "【PF Core Subroutine】☞ Update node meta"
    
    if eventPlayer.pfCurrentNodeIndex != -1:
        eventPlayer.pfActiveNode = eventPlayer.pfCurrentNodeIndex
    if eventPlayer.pfStuckOnNode == 1:
        eventPlayer.pfStuckOnNode = 0
    #Update the pathfinding start time.
    eventPlayer.pfStartTime = getTotalTimeElapsed()
    eventPlayer.pfWalkingFromPosition = eventPlayer.getPosition()


def pfWalkToDestination():
    @Name "☆【PF Core Subroutine】☞ Walk to destination"
    
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.pfWalkingToPosition), eventPlayer.pfWalkingToPosition and (eventPlayer.pfCurrentNodeIndex != -1 or distance(eventPlayer.getPosition(), eventPlayer.pfWalkingToPosition) > 0.4), Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)


rule "【PF Core】Update & Execute":
    @Event eachPlayer
    @Condition eventPlayer.pfDestination == true
    @Condition distance(eventPlayer, eventPlayer.pfDestination) > 4
    @Condition (not eventPlayer.pfSavedTarget or distance(eventPlayer.pfDestination, eventPlayer.pfSavedTarget) > 5) == true
    
    #Ensure that a map is loaded.
    if not pfLoadedMap_nodes:
        printLog("Error: Attempted to pathfind player {0} without a loaded map.".format(eventPlayer))
        return
    eventPlayer.pfWait = getTotalTimeElapsed()
    eventPlayer.pfWasBroadcasted = false
    waitUntil(pfExecOwner == eventPlayer or eventPlayer.pfWasBroadcasted, 9999)
    #Update saved destination
    eventPlayer.pfSavedTarget = eventPlayer.pfDestination
    if not eventPlayer.pfWasBroadcasted:
        eventPlayer.goal = floor(((abs(((sorted(sorted(pfLoadedMap_nodes, lambda player: distance(player, eventPlayer.pfSavedTarget)).slice(0, 5), lambda i_: not isInLoS(i_ + vect(0, 2, 0), eventPlayer.pfSavedTarget + vect(0, 2, 0), BarrierLos.PASS_THROUGH_BARRIERS)))[0]).y)) * 1000) % 1000)
        pfTick()
        if eventPlayer.pfIsPathfinding and eventPlayer.pfCurrentNodeIndex != -1:
            eventPlayer.pfActiveNode = eventPlayer.pfCurrentNodeIndex
        else:
            eventPlayer.pfActiveNode = floor(((abs(((sorted(sorted(pfLoadedMap_nodes, lambda player: distance(player, eventPlayer.getPosition())).slice(0, 5), lambda i_: not isInLoS(i_ + vect(0, 2, 0), eventPlayer.getPosition() + vect(0, 2, 0), BarrierLos.PASS_THROUGH_BARRIERS)))[0]).y)) * 1000) % 1000)
            pfTick()
        eventPlayer.scores_gScore = [0]
        eventPlayer.scores_fScore = [0]
        eventPlayer.scores_parent = [-1]
        eventPlayer.scores_nodeIndex = [eventPlayer.goal]
        eventPlayer.open = [0]
        eventPlayer.checkedNode = eventPlayer.pfActiveNode
        eventPlayer.iter = 0
        while len(eventPlayer.open) or eventPlayer.iter > 30:
            #The index of the current node in `scores`.
            eventPlayer.current = sorted(eventPlayer.open, lambda player: eventPlayer.scores_fScore[player])[0]
            if eventPlayer.checkedNode != eventPlayer.pfActiveNode:
                eventPlayer.checkedNode = eventPlayer.scores_nodeIndex.index(eventPlayer.pfActiveNode)
                if eventPlayer.checkedNode != -1:
                    eventPlayer.current = eventPlayer.checkedNode
                    eventPlayer.checkedNode = -2
                else:
                    eventPlayer.checkedNode = eventPlayer.pfActiveNode
            eventPlayer.currentInExistingPath = eventPlayer.pfPath.index(eventPlayer.scores_nodeIndex[eventPlayer.current])
            #If the goal was found, reconstruct the path.
            if eventPlayer.scores_nodeIndex[eventPlayer.current] == eventPlayer.pfActiveNode or eventPlayer.checkedNode == -2 or eventPlayer.currentInExistingPath != -1:
                if eventPlayer.currentInExistingPath == -1:
                    eventPlayer.pfPath = []
                else:
                    eventPlayer.pfPath = eventPlayer.pfPath.slice(0, eventPlayer.currentInExistingPath)
                while eventPlayer.current != -1:
                    eventPlayer.pfPath.append(eventPlayer.scores_nodeIndex[eventPlayer.current])
                    eventPlayer.current = eventPlayer.scores_parent[eventPlayer.current]
                eventPlayer.pfPath.append([-1])
                eventPlayer.broadcastTo = [player for player in getPlayersInRadius(eventPlayer.getPosition() + Vector.UP, 4, Team.ALL, LosCheck.OFF) if player != eventPlayer and player.pfWait and distance(player.pfDestination, eventPlayer.pfDestination) < 4 and player.pfPlayerAttributes == eventPlayer.pfPlayerAttributes]
                eventPlayer.broadcastTo.pfPath = eventPlayer.pfPath
                eventPlayer.broadcastTo.pfWasBroadcasted = true
                goto lbl_0
            eventPlayer.open.remove(eventPlayer.current)
            #Check each neighbor to the current node.
            for eventPlayer.neighbor in range(len(pfLoadedMap_neighbors[eventPlayer.scores_nodeIndex[eventPlayer.current]])):
                #The neighbor index to be used like `pfLoadedMap.nodes[neighborI]`.
                eventPlayer.neighborI = pfLoadedMap_neighbors[eventPlayer.scores_nodeIndex[eventPlayer.current]][eventPlayer.neighbor][0]
                eventPlayer.scoreIndex = eventPlayer.scores_nodeIndex.index(eventPlayer.neighborI)
                #Ensure that the path to the neighbor is enabled.
                if len(pfLoadedMap_neighbors[eventPlayer.scores_nodeIndex[eventPlayer.current]][eventPlayer.neighbor][1]) == 0 or any([i_ in eventPlayer.pfPlayerAttributes for i_ in pfLoadedMap_neighbors[eventPlayer.scores_nodeIndex[eventPlayer.current]][eventPlayer.neighbor][1]]):
                    eventPlayer.score = eventPlayer.scores_gScore[eventPlayer.current] + distance(pfLoadedMap_nodes[eventPlayer.scores_nodeIndex[eventPlayer.current]], pfLoadedMap_nodes[eventPlayer.neighborI])
                    #Get neighbor index in scores.
                    #If -1, the neighbor was not added to the score list yet.
                    if eventPlayer.scoreIndex == -1:
                        eventPlayer.open.append(len(eventPlayer.scores_gScore))
                        eventPlayer.scores_gScore.append(eventPlayer.score)
                        eventPlayer.scores_fScore.append(eventPlayer.score + distance(pfLoadedMap_nodes[eventPlayer.neighborI], pfLoadedMap_nodes[eventPlayer.pfActiveNode]) * 20)
                        eventPlayer.scores_parent.append(eventPlayer.current)
                        eventPlayer.scores_nodeIndex.append(eventPlayer.neighborI)
                    elif eventPlayer.score < eventPlayer.scores_gScore[eventPlayer.scoreIndex]:
                        eventPlayer.scores_gScore[eventPlayer.scoreIndex] = eventPlayer.score
                        eventPlayer.scores_fScore[eventPlayer.scoreIndex] = eventPlayer.score + distance(pfLoadedMap_nodes[eventPlayer.neighborI], pfLoadedMap_nodes[eventPlayer.pfActiveNode]) * 20
                        eventPlayer.scores_parent[eventPlayer.scoreIndex] = eventPlayer.current
                        eventPlayer.scores_nodeIndex[eventPlayer.scoreIndex] = eventPlayer.neighborI
                        if not eventPlayer.scoreIndex in eventPlayer.open:
                            eventPlayer.open.append(eventPlayer.scoreIndex)
                pfTick()
            eventPlayer.iter += 1
        lbl_0:
        pfExecOwner = null
    if len(eventPlayer.pfPath):
        eventPlayer.pfIsPathfinding = true
        eventPlayer.pfCurrentNodeIndex = eventPlayer.pfPath[0]
        eventPlayer.pfWalkingToPosition = pfLoadedMap_nodes[eventPlayer.pfCurrentNodeIndex]
        pfUpdateNodeMeta()
        pfWalkToDestination()
    eventPlayer.pfWait = null
    wait(2)
    if RULE_CONDITION:
        goto RULE_START


def pfProgressEventPlayer():
    @Name "【PF Core Subroutine】☞ Progress event player"
    
    if len(eventPlayer.pfPath) == 0:
        goto lbl_0
    #Pop the current path.
    del eventPlayer.pfPath[0]
    #Update the current pathfind attributes.
    if len(eventPlayer.pfPath) and eventPlayer.pfPath[0] != -1:
        #Any rules watching these with the matching condition will activate.
        eventPlayer.pfAttributes = (([i_ for i_ in pfLoadedMap_neighbors[eventPlayer.pfPath[0]] if i_[0] == eventPlayer.pfCurrentNodeIndex])[0]).last()
    else:
        eventPlayer.pfAttributes = []
    #Go to the next node in the path.
    eventPlayer.pfCurrentNodeIndex = eventPlayer.pfPath[0]
    #Set the position that the player is currently walking towards.
    eventPlayer.pfWalkingToPosition = (eventPlayer.pfDestination if distance(eventPlayer.pfDestination, eventPlayer.pfSavedTarget) <= 4 else eventPlayer.getPosition()) if eventPlayer.pfCurrentNodeIndex == -1 else pfLoadedMap_nodes[eventPlayer.pfCurrentNodeIndex]
    pfUpdateNodeMeta()
    lbl_0:


rule "【PF Core】Node reached":
    @Event eachPlayer
    @Condition eventPlayer.pfIsPathfinding == true
    @Condition eventPlayer.pfWalkingToPosition == true
    @Condition distance(eventPlayer.getPosition() * vect(1, [], 1), eventPlayer.pfWalkingToPosition * vect(1, [], 1)) <= 0.4
    @Condition abs(eventPlayer.getPosition().y - eventPlayer.pfWalkingToPosition.y) <= 1.5
    @Condition len(eventPlayer.pfPath) > 0
    @Condition eventPlayer.pfCurrentNodeIndex != -1
    
    pfProgressEventPlayer()
    wait(0.2)
    if RULE_CONDITION:
        goto RULE_START


rule "【PF Core】Stop throttle when pfDestination is reset":
    @Event eachPlayer
    @Condition eventPlayer.pfIsPathfinding == true
    @Condition eventPlayer.pfDestination == null
    
    eventPlayer.stopThrottleInDirection()
    eventPlayer.pfIsPathfinding = false
    eventPlayer.pfSavedTarget = null


def pfRecalibrate():
    @Name "【PF Core Subroutine】☞ Recalibrate"
    
    eventPlayer.stopThrottleInDirection()
    eventPlayer.pfCurrentNodeIndex = -1
    eventPlayer.pfSavedTarget = null
    eventPlayer.pfIsPathfinding = false
    eventPlayer.pfWalkingToPosition = eventPlayer.getPosition()


rule "【PF Core】Insurance":
    @Event eachPlayer
    @Condition eventPlayer.pfIsPathfinding == true
    @Condition eventPlayer.pfWalkingToPosition == true
    
    #Recalibrate
    if distance((eventPlayer.pfWalkingFromPosition + eventPlayer.pfWalkingToPosition) / 2, eventPlayer) > (distance(eventPlayer.pfWalkingFromPosition, eventPlayer.pfWalkingToPosition) + 2) * 1.2:
        pfRecalibrate()
        #Smooth step
    elif len(eventPlayer.pfPath) == 2 and distance(eventPlayer, eventPlayer.pfSavedTarget) < distance(eventPlayer.pfWalkingToPosition, eventPlayer.pfSavedTarget) and isInLoS(eventPlayer.getPosition() + vect(0, 0.25, 0), eventPlayer.pfSavedTarget + vect(0, 0.25, 0), BarrierLos.PASS_THROUGH_BARRIERS):
        pfProgressEventPlayer()
        #Recovery
    elif distance(eventPlayer, eventPlayer.pfWalkingToPosition) > 0.25 and eventPlayer.pfIsStuck or distance(eventPlayer.pfWalkingFromPosition, eventPlayer.pfWalkingToPosition) - (4.95 * (getTotalTimeElapsed() - eventPlayer.pfStartTime)) < 0 and not eventPlayer.hasStatusEffect(Status.ROOTED) and not eventPlayer.hasStatusEffect(Status.FROZEN) and not eventPlayer.hasStatusEffect(Status.ASLEEP) and not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) and not eventPlayer.hasStatusEffect(Status.STUNNED):
        if eventPlayer.pfCurrentNodeIndex == -1:
            eventPlayer.pfWalkingToPosition = null
        elif eventPlayer.pfStuckOnNode - 2 == eventPlayer.pfCurrentNodeIndex:
            printLog("Pathfinder {0} struggled to reach node {1} at {2}. Try adjusting your map in the editor.".format(eventPlayer, eventPlayer.pfCurrentNodeIndex, pfLoadedMap_nodes[eventPlayer.pfCurrentNodeIndex]))
            eventPlayer.teleport(eventPlayer.pfWalkingToPosition)
        else:
            eventPlayer.pfStuckOnNode = eventPlayer.pfCurrentNodeIndex + 2
            pfRecalibrate()
        #Shift destination
    elif eventPlayer.pfWalkingToPosition != eventPlayer.pfDestination and eventPlayer.pfCurrentNodeIndex == -1 and distance(eventPlayer.pfSavedTarget, eventPlayer.pfDestination) < 5 and isInLoS(eventPlayer.pfSavedTarget + Vector.UP, eventPlayer.pfDestination + Vector.UP, BarrierLos.PASS_THROUGH_BARRIERS):
        eventPlayer.pfWalkingToPosition = eventPlayer.pfDestination
    wait(2)
    if RULE_CONDITION:
        goto RULE_START


rule "【PF Core】Check throttle":
    @Event eachPlayer
    @Condition eventPlayer.pfIsPathfinding == true
    @Condition magnitude(eventPlayer.getVelocity()) < 3
    
    wait(2.1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.pfIsStuck = true
    waitUntil(not eventPlayer.pfWalkingToPosition or not eventPlayer.pfIsPathfinding or magnitude(eventPlayer.getVelocity()) >= 3, 9999)
    eventPlayer.pfIsStuck = false


def pfLookAtDestination():
    @Name "☆【PF Core Subroutine】☞ Look at destination"
    
    #Calling this subroutine will make the player look to the point they are walking towards.
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition() * (vect(1, [], 1) if distance(eventPlayer.getPosition(), eventPlayer.pfWalkingToPosition) < 3 else vect(1, 1, 1)), (eventPlayer.pfWalkingToPosition + vect(0, 1.5, 0)) * (vect(1, [], 1) if distance(eventPlayer.getPosition(), eventPlayer.pfWalkingToPosition) < 3 else vect(1, 1, 1))), 500, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)


