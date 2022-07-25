using TreeNodeClassification
using Test

@testset "Test Known Network" begin
    using TreeNodeClassification
    using Graphs

    ##
    # Generate a graph with known classes
    known_node_classes = Vector{Any}(undef, 11)
    g = path_graph(7)
    add_edge!(g, 1, 7)
    add_vertices!(g, 4)

    known_node_classes[1] = "Root"
    known_node_classes[2] = "Root"
    known_node_classes[7] = "Root"

    known_node_classes[3:6] .= "Bulk"

    # Dense Sprout
    add_edge!(g, 7, 8)
    add_edge!(g, 7, 5)
    add_edge!(g, 7, 4)
    add_edge!(g, 7, 3)
    add_edge!(g, 7, 2)
    known_node_classes[8] = "Dense Sprout"

    # Sparse Sprout
    add_edge!(g, 1, 9)
    known_node_classes[9] = "Sparse Sprout"

    # Inner Tree Node and Proper Leaf
    add_edge!(g, 2, 10)
    add_edge!(g, 10, 11)
    known_node_classes[10] = "Inner Tree Node"
    known_node_classes[11] = "Proper Leaf"

    ##
    # Tree Node Classification
    threshold = 5
    node_classes = full_node_classification(g, 1000, threshold)

    @test node_classes == known_node_classes
end
