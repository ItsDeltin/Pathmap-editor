#Global variables

globalvar pfLoadedMap_nodes
globalvar pfLoadedMap_neighbors
globalvar pfIterationsThisTick


#Player variables

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
playervar pfNextPosition
playervar pfActiveNode
playervar pfStuckOnNode
playervar goal
playervar scores_gScore
playervar scores_fScore
playervar scores_parent
playervar scores_nodeIndex
playervar open
playervar checkedNode
playervar iter
playervar current
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


rule "【PF Core】Next Tick":
    @Condition pfIterationsThisTick <= 0
    @Condition getAverageServerLoad() < 255
    
    pfIterationsThisTick = max(min(round(63 - getAverageServerLoad() / 4), 15), 2)
    wait(0.016 if getAverageServerLoad() < 255 else 0.3)
    if RULE_CONDITION:
        goto RULE_START


def pfTick():
    @Name "【PF Core Subroutine】☞ Tick"
    
    while pfIterationsThisTick <= 0:
        waitUntil(pfIterationsThisTick > 0, 9999)
    pfIterationsThisTick -= 1


def pfUpdateNodeMeta():
    @Name "【PF Core Subroutine】☞ Update node meta"
    
    if eventPlayer.pfCurrentNodeIndex != -1:
        eventPlayer.pfActiveNode = eventPlayer.pfCurrentNodeIndex
    if eventPlayer.pfStuckOnNode == 1:
        eventPlayer.pfStuckOnNode = 0
    #Update the pathfinding start time.
    eventPlayer.pfStartTime = getTotalTimeElapsed()
    eventPlayer.pfWalkingFromPosition = eventPlayer.getPosition()
    eventPlayer.pfNextPosition = 0 if len(eventPlayer.pfPath) == 0 else pfLoadedMap_nodes[eventPlayer.pfPath[0]]


def pfWalkToDestination():
    @Name "☆【PF Core Subroutine】☞ Walk to destination"
    
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.pfDestination if eventPlayer.pfCurrentNodeIndex == -1 and distance(eventPlayer.pfDestination, eventPlayer.pfSavedTarget) < 6 else eventPlayer.pfWalkingToPosition), distance(eventPlayer.getPosition(), eventPlayer.pfDestination), Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)


rule "【PF Core】Update & Execute":
    @Event eachPlayer
    @Condition eventPlayer.pfDestination == true
    @Condition distance(eventPlayer, eventPlayer.pfDestination) > 4
    @Condition (not eventPlayer.pfSavedTarget or distance(eventPlayer.pfDestination, eventPlayer.pfSavedTarget) > 5) == true
    
    #Ensure that a map is loaded.
    if not pfLoadedMap_nodes:
        printLog("Error: Attempted to pathfind player {0} without a loaded map.".format(eventPlayer))
        return
    #Update saved destination
    eventPlayer.goal = pfLoadedMap_nodes.index((sorted(sorted(pfLoadedMap_nodes, lambda player: distance(player, eventPlayer.pfDestination)).slice(0, 5), lambda i: not (isInLoS(i + vect(0, 2, 0), eventPlayer.pfDestination + vect(0, 2, 0), BarrierLos.PASS_THROUGH_BARRIERS) and abs(eventPlayer.pfDestination.y - i.y) < distance(eventPlayer.pfDestination, i) / 2)))[0])
    pfTick()
    if eventPlayer.pfIsPathfinding and eventPlayer.pfCurrentNodeIndex != -1:
        eventPlayer.pfActiveNode = eventPlayer.pfCurrentNodeIndex
    else:
        eventPlayer.pfActiveNode = pfLoadedMap_nodes.index((sorted(sorted(pfLoadedMap_nodes, lambda player: distance(player, eventPlayer.getPosition())).slice(0, 5), lambda i: not (isInLoS(i + vect(0, 2, 0), eventPlayer.getPosition() + vect(0, 2, 0), BarrierLos.PASS_THROUGH_BARRIERS) and abs(eventPlayer.getPosition().y - i.y) < distance(eventPlayer.getPosition(), i) / 2)))[0])
        pfTick()
    eventPlayer.scores_gScore = [0]
    eventPlayer.scores_fScore = [0]
    eventPlayer.scores_parent = [-1]
    eventPlayer.scores_nodeIndex = [eventPlayer.goal]
    eventPlayer.open = [0]
    eventPlayer.checkedNode = eventPlayer.pfActiveNode
    eventPlayer.iter = 0
    while len(eventPlayer.open):
        eventPlayer.current = sorted(eventPlayer.open, lambda player: eventPlayer.scores_fScore[player])[0]
        if eventPlayer.checkedNode != eventPlayer.pfActiveNode:
            eventPlayer.checkedNode = eventPlayer.scores_nodeIndex.index(eventPlayer.pfActiveNode)
            if eventPlayer.checkedNode != -1:
                eventPlayer.current = eventPlayer.checkedNode
                eventPlayer.pfPath = []
                while eventPlayer.current != -1:
                    eventPlayer.pfPath.append(eventPlayer.scores_nodeIndex[eventPlayer.current])
                    eventPlayer.current = eventPlayer.scores_parent[eventPlayer.current]
                    pfTick()
                eventPlayer.pfPath.append([-1])
                goto lbl_0
            eventPlayer.checkedNode = eventPlayer.pfActiveNode
        #If the goal was found, reconstruct the path.
        if eventPlayer.scores_nodeIndex[eventPlayer.current] == eventPlayer.pfActiveNode:
            eventPlayer.pfPath = []
            while eventPlayer.current != -1:
                eventPlayer.pfPath.append(eventPlayer.scores_nodeIndex[eventPlayer.current])
                eventPlayer.current = eventPlayer.scores_parent[eventPlayer.current]
                pfTick()
            eventPlayer.pfPath.append([-1])
            goto lbl_1
        eventPlayer.open.remove(eventPlayer.current)
        #Check each neighbor to the current node.
        for eventPlayer.neighbor in range(len(pfLoadedMap_neighbors[eventPlayer.scores_nodeIndex[eventPlayer.current]])):
            #The neighbor index to be used like `pfLoadedMap.nodes[neighborI]`.
            eventPlayer.neighborI = pfLoadedMap_neighbors[eventPlayer.scores_nodeIndex[eventPlayer.current]][eventPlayer.neighbor][0]
            eventPlayer.scoreIndex = eventPlayer.scores_nodeIndex.index(eventPlayer.neighborI)
            #Ensure that the path to the neighbor is enabled.
            if all([i in eventPlayer.pfPlayerAttributes for i in pfLoadedMap_neighbors[eventPlayer.scores_nodeIndex[eventPlayer.current]][eventPlayer.neighbor][1]]):
                eventPlayer.score = eventPlayer.scores_gScore[eventPlayer.current] + distance(pfLoadedMap_nodes[eventPlayer.scores_nodeIndex[eventPlayer.current]], pfLoadedMap_nodes[eventPlayer.neighborI])
                #Get neighbor index in scores.
                #If -1, the neighbor was not added to the score list yet.
                if eventPlayer.scoreIndex == -1:
                    #Note: not required after debugging.
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
    lbl_1:
    eventPlayer.pfSavedTarget = eventPlayer.pfDestination
    eventPlayer.pfIsPathfinding = true
    eventPlayer.pfCurrentNodeIndex = eventPlayer.pfPath[0]
    eventPlayer.pfWalkingToPosition = pfLoadedMap_nodes[eventPlayer.pfCurrentNodeIndex]
    pfUpdateNodeMeta()
    pfWalkToDestination()
    wait(2)
    if RULE_CONDITION:
        goto RULE_START


def pfProgressEventPlayer():
    @Name "【PF Core Subroutine】☞ Progress event player"
    
    if len(eventPlayer.pfPath) == 0:
        goto lbl_0
    #Update the current pathfind attributes.
    #Any rules watching these with the matching condition will activate.
    eventPlayer.pfAttributes = (([i for i in pfLoadedMap_neighbors[eventPlayer.pfCurrentNodeIndex] if i[0] == eventPlayer.pfPath[0]])[0]).last()
    #Go to the next node in the path.
    eventPlayer.pfCurrentNodeIndex = eventPlayer.pfPath[0]
    #Pop the current path.
    del eventPlayer.pfPath[0]
    #Set the position that the player is currently walking towards.
    eventPlayer.pfWalkingToPosition = eventPlayer.pfSavedTarget if eventPlayer.pfCurrentNodeIndex == -1 else pfLoadedMap_nodes[eventPlayer.pfCurrentNodeIndex]
    pfUpdateNodeMeta()
    lbl_0:


rule "【PF Core】Node reached":
    @Event eachPlayer
    @Condition eventPlayer.pfIsPathfinding == true
    @Condition distance(eventPlayer, eventPlayer.pfWalkingToPosition) <= 0.4
    
    #The player reached the next node in the path to the destination.
    if eventPlayer.pfCurrentNodeIndex == -1:
        #The destination was reached, stop pathfinding.
        eventPlayer.pfIsPathfinding = false
    else:
        pfProgressEventPlayer()
    wait(0.2)
    if RULE_CONDITION:
        goto RULE_START


rule "【PF Core】(optional) Stop throttle when pfDestination is reset":
    @Event eachPlayer
    @Condition eventPlayer.pfIsPathfinding == true
    @Condition eventPlayer.pfDestination == null
    
    eventPlayer.stopThrottleInDirection()
    eventPlayer.pfIsPathfinding = false


def pfRecalibrate():
    @Name "【PF Core Subroutine】☞ Recalibrate"
    
    eventPlayer.stopThrottleInDirection()
    eventPlayer.pfCurrentNodeIndex = -1
    eventPlayer.pfSavedTarget = null
    eventPlayer.pfIsPathfinding = false


rule "【PF Core】(optional) Recalibrate when off the path":
    @Event eachPlayer
    @Condition eventPlayer.pfIsPathfinding == true
    @Condition distance((eventPlayer.pfWalkingFromPosition + eventPlayer.pfWalkingToPosition) / 2, eventPlayer) > distance(eventPlayer.pfWalkingFromPosition, eventPlayer.pfWalkingToPosition) * 2
    
    wait(2, Wait.ABORT_WHEN_FALSE)
    pfRecalibrate()


rule "【PF Core】(optional) Skip node when shortcut is found":
    @Event eachPlayer
    @Condition eventPlayer.pfIsPathfinding == true
    @Condition eventPlayer.pfCurrentNodeIndex != -1
    @Condition isInLoS(eventPlayer.getPosition() + vect(0, 0.25, 0), eventPlayer.pfNextPosition + vect(0, 0.25, 0), BarrierLos.PASS_THROUGH_BARRIERS) == true
    
    wait(0.1)
    pfProgressEventPlayer()
    if RULE_CONDITION:
        goto RULE_START


rule "【PF Core】(optional) Recover when stuck or time to next node takes longer than expected":
    @Event eachPlayer
    @Condition eventPlayer.pfIsPathfinding == true
    @Condition distance(eventPlayer.getPosition(), eventPlayer.pfDestination) > 5
    @Condition (magnitude(eventPlayer.getVelocity()) < 3 or distance(eventPlayer.pfWalkingFromPosition, eventPlayer.pfWalkingToPosition) - (4.95 * (getTotalTimeElapsed() - eventPlayer.pfStartTime)) < 0) == true
    @Condition (not eventPlayer.hasStatusEffect(Status.ROOTED)) == true
    @Condition (not eventPlayer.hasStatusEffect(Status.FROZEN)) == true
    @Condition (not eventPlayer.hasStatusEffect(Status.ASLEEP)) == true
    @Condition (not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN)) == true
    @Condition (not eventPlayer.hasStatusEffect(Status.STUNNED)) == true
    
    #Ensure condition is true for at least 3 seconds.
    wait(3, Wait.ABORT_WHEN_FALSE)
    #When the bot gets stuck while pathfinding,
    if eventPlayer.pfStuckOnNode - 2 == eventPlayer.pfCurrentNodeIndex:
        if eventPlayer.pfCurrentNodeIndex != -1:
            printLog("Pathfinder {0} struggled to reach node {1} at {2}. Try adjusting your map in the editor.".format(eventPlayer, eventPlayer.pfCurrentNodeIndex, pfLoadedMap_nodes[eventPlayer.pfCurrentNodeIndex]))
        eventPlayer.teleport(eventPlayer.pfWalkingToPosition)
    else:
        eventPlayer.pfStuckOnNode = eventPlayer.pfCurrentNodeIndex + 2
        pfRecalibrate()
    if RULE_CONDITION:
        goto RULE_START


def pfLookAtDestination():
    @Name "☆【PF Core Subroutine】☞ Look at destination"
    
    #Calling this subroutine will make the player look to the point they are walking towards.
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition() * (vect(1, 0, 1) if distance(eventPlayer.getPosition(), eventPlayer.pfWalkingToPosition) < 3 else vect(1, 1, 1)), (eventPlayer.pfWalkingToPosition + Vector.UP * 1.5) * (vect(1, 0, 1) if distance(eventPlayer.getPosition(), eventPlayer.pfWalkingToPosition) < 3 else vect(1, 1, 1))), 500, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)


