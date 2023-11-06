import python

module InterproceduralControlFlow {
    // TODO this might lead to infite recursion, have to put a time limit (or something) when using this function
    predicate reaches(ControlFlowNode source, ControlFlowNode sink) {
        source.strictlyReaches(sink)
        and exists(sink.getLocation().getFile().getRelativePath())
        and exists(source.getLocation().getFile().getRelativePath())
        or exists(Call c, Function f | 
            source.strictlyReaches(c.getAFlowNode())
            and c.getFunc().toString() = f.getName()
            and exists(c.getLocation().getFile().getRelativePath())
            and exists(f.getLocation().getFile().getRelativePath())
            and reaches(f.getAFlowNode(), sink))
    }

    // TODO this might lead to infite recursion, have to put a time limit (or something) when using this function
    // Interprocedural reachability query which also checks that the barrier control flow node is not in the path between source and sink
    predicate reachesWithBarrier(ControlFlowNode source, ControlFlowNode sink, ControlFlowNode barrier) {
        source.strictlyReaches(sink)
        and not (source.strictlyReaches(barrier) and barrier.strictlyReaches(sink))
        and exists(sink.getLocation().getFile().getRelativePath())
        and exists(source.getLocation().getFile().getRelativePath())
        or exists(Call c, Function f | 
            source.strictlyReaches(c.getAFlowNode())
            and not (source.strictlyReaches(barrier) and barrier.strictlyReaches(c.getAFlowNode()))
            and c.getFunc().toString() = f.getName()
            and exists(c.getLocation().getFile().getRelativePath())
            and exists(f.getLocation().getFile().getRelativePath())
            and reachesWithBarrier(f.getAFlowNode(), sink, barrier))
    }
}