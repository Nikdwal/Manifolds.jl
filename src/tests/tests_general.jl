"""
    test_manifold(
        M::Manifold,
        pts::AbstractVector;
        args,
    )

Test general properties of manifold `M`, given at least three different points
that lie on it (contained in `pts`).

# Arguments
- `basis_has_specialized_diagonalizing_get = false`: if true, assumes that
    [`DiagonalizingOrthonormalBasis`](@ref) given in `basis_types` has
    [`get_coordinates`](@ref) and [`get_vector`](@ref) that work without caching.
- `basis_types_to_from = ()`: basis types that will be tested based on
    [`get_coordinates`](@ref) and [`get_vector`](@ref).
- `basis_types_vecs = ()` : basis types that will be tested based on [`get_vectors`](@ref).
- `default_inverse_retraction_method = ManifoldsBase.LogarithmicInverseRetraction()`:
    default method for inverse retractions ([`log`](@ref)).
- `default_retraction_method = ManifoldsBase.ExponentialRetraction()`: default method for
    retractions ([`exp`](@ref)).
- `exp_log_atol_multiplier = 0`: change absolute tolerance of exp/log tests
    (0 use default, i.e. deactivate atol and use rtol).
- `exp_log_rtol_multiplier = 1`: change the relative tolerance of exp/log tests
    (1 use default). This is deactivated if the `exp_log_atol_multiplier` is nonzero.
- `expected_dimension_type = Integer`: expected type of value returned by
    [`manifold_dimension`](@ref).
- `inverse_retraction_methods = []`: inverse retraction methods that will be tested.
- `is_mutating = true`: whether mutating variants of functions should be tested.
- `is_point_atol_multiplier = 0`: determines atol of `is_manifold_point` checks.
- `is_tangent_atol_multiplier = 0`: determines atol of `is_tangent_vector` checks.
- `mid_point12 = test_exp_log ? shortest_geodesic(M, pts[1], pts[2], 0.5) : nothing`: if not `nothing`, then check
    that `mid_point(M, pts[1], pts[2])` is approximately equal to `mid_point12`. This is
    by default set to `nothing` if `text_exp_log` is set to false.
- `point_distributions = []` : point distributions to test.
- `rand_tvector_atol_multiplier = 0` : chage absolute tolerance in testing random vectors
    (0 use default, i.e. deactivate atol and use rtol) random tangent vectors are tangent
    vectors.
- `retraction_atol_multiplier = 0`: change absolute tolerance of (inverse) retraction tests
    (0 use default, i.e. deactivate atol and use rtol).
- `retraction_rtol_multiplier = 1`: change the relative tolerance of (inverse) retraction
    tests (1 use default). This is deactivated if the `exp_log_atol_multiplier` is nonzero.
- `retraction_methods = []`: retraction methods that will be tested.
- `test_exp_log = true`: if true, checkthat [`exp`](@ref) is the inverse of [`log`](@ref).
- `test_forward_diff = true`: if true, automatic differentiation using
    ForwardDiff is tested.
- `test_injectivity_radius = true`: whether implementation of [`injectivity_radius`](@ref)
    should be tested.
- `test_is_tangent`: if true check that the `default_inverse_retraction_method`
    actually returns valid tangent vectors.
- `test_musical_isomorphisms = false` : test musical isomorphisms.
- `test_mutating_rand = false` : test the mutating random function for points on manifolds.
- `test_project_point = false`: test projections onto the manifold.
- `test_project_tangent = false` : test projections on tangent spaces.
- `test_representation_size = true` : test repersentation size of points/tvectprs.
- `test_reverse_diff = true`: if true, automatic differentiation using
    ReverseDiff is tested.
- `test_tangent_vector_broadcasting = true` : test boradcasting operators on TangentSpace.
- `test_vector_spaces = true` : test Vector bundle of this manifold.
- `test_default_vector_transport = false` : test the default vector transport (usually
   parallel transport).
- `test_vee_hat = false`: test [`vee`](@ref) and [`hat`](@ref) functions.
- `tvector_distributions = []` : tangent vector distributions to test.
- `vector_transport_methods = []`: vector transport methods that should be tested.
- `vector_transport_inverse_retractions = [default_inverse_retraction_method for _ in 1:length(vector_transport_methods)]``
  inverse retractions to use with the vector transport method (especially the differentiated ones)
- `vector_transport_to = [ true for _ in 1:length(vector_transport_methods)]`: whether
   to check the `to` variant of vector transport
- `vector_transport_direction = [ true for _ in 1:length(vector_transport_methods)]`: whether
   to check the `direction` variant of vector transport
"""
function ManifoldTests.test_manifold(
    M::Manifold,
    pts::AbstractVector;
    basis_has_specialized_diagonalizing_get=false,
    basis_types_to_from=(),
    basis_types_vecs=(),
    default_inverse_retraction_method=LogarithmicInverseRetraction(),
    default_retraction_method=ExponentialRetraction(),
    exp_log_atol_multiplier=0,
    exp_log_rtol_multiplier=1,
    expected_dimension_type=Integer,
    inverse_retraction_methods=[],
    is_mutating=true,
    is_point_atol_multiplier=0,
    is_tangent_atol_multiplier=0,
    point_distributions=[],
    projection_atol_multiplier=0,
    rand_tvector_atol_multiplier=0,
    retraction_atol_multiplier=0,
    retraction_methods=[],
    retraction_rtol_multiplier=1,
    test_exp_log=true,
    test_forward_diff=true,
    test_is_tangent=true,
    test_injectivity_radius=true,
    test_musical_isomorphisms=false,
    test_mutating_rand=false,
    test_project_point=false,
    test_project_tangent=false,
    test_representation_size=true,
    test_reverse_diff=true,
    test_tangent_vector_broadcasting=true,
    test_default_vector_transport=false,
    test_vector_spaces=true,
    test_vee_hat=false,
    tvector_distributions=[],
    vector_transport_methods=[],
    vector_transport_inverse_retractions=[
        default_inverse_retraction_method for _ in 1:length(vector_transport_methods)
    ],
    vector_transport_retractions=[
        default_retraction_method for _ in 1:length(vector_transport_methods)
    ],
    test_vector_transport_to=[true for _ in 1:length(vector_transport_methods)],
    test_vector_transport_direction=[true for _ in 1:length(vector_transport_methods)],
    mid_point12=test_exp_log ? shortest_geodesic(M, pts[1], pts[2], 0.5) : nothing,
)
    length(pts) ≥ 3 || error("Not enough points (at least three expected)")
    isapprox(M, pts[1], pts[2]) && error("Points 1 and 2 are equal")
    isapprox(M, pts[1], pts[3]) && error("Points 1 and 3 are equal")

    # get a default tangent vector for every of the three tangent spaces
    n = length(pts)
    if default_inverse_retraction_method === nothing
        tv = [zero_tangent_vector(M, pts[i]) for i in 1:n] # no other available
    else
        tv = [
            inverse_retract(
                M,
                pts[i],
                pts[((i + 1) % n) + 1],
                default_inverse_retraction_method,
            ) for i in 1:n
        ]
    end
    Test.Test.@testset "dimension" begin
        Test.@test isa(manifold_dimension(M), expected_dimension_type)
        Test.@test manifold_dimension(M) ≥ 0
        Test.@test manifold_dimension(M) == vector_space_dimension(
            Manifolds.VectorBundleFibers(Manifolds.TangentSpace, M),
        )
        Test.@test manifold_dimension(M) == vector_space_dimension(
            Manifolds.VectorBundleFibers(Manifolds.CotangentSpace, M),
        )
    end

    test_representation_size && Test.@testset "representation" begin
        function test_repr(repr)
            Test.@test isa(repr, Tuple)
            for rs in repr
                Test.@test rs > 0
            end
            return nothing
        end

        test_repr(Manifolds.representation_size(M))
        for fiber in (Manifolds.TangentSpace, Manifolds.CotangentSpace)
            test_repr(Manifolds.representation_size(Manifolds.VectorBundleFibers(fiber, M)))
        end
    end

    test_injectivity_radius && Test.@testset "injectivity radius" begin
        Test.@test injectivity_radius(M, pts[1]) > 0
        Test.@test injectivity_radius(M, pts[1]) ≥ injectivity_radius(M)
        for rm in retraction_methods
            Test.@test injectivity_radius(M, rm) > 0
            Test.@test injectivity_radius(M, pts[1], rm) ≥ injectivity_radius(M, rm)
            Test.@test injectivity_radius(M, pts[1], rm) ≤ injectivity_radius(M, pts[1])
        end
    end

    Test.@testset "is_manifold_point" begin
        for pt in pts
            atol = is_point_atol_multiplier * ManifoldTests.find_eps(pt)
            Test.@test is_manifold_point(M, pt; atol=atol)
            Test.@test check_manifold_point(M, pt; atol=atol) === nothing
        end
    end

    test_is_tangent && Test.@testset "is_tangent_vector" begin
        for (p, X) in zip(pts, tv)
            atol = is_tangent_atol_multiplier * ManifoldTests.find_eps(p)
            if !(check_tangent_vector(M, p, X; atol=atol) === nothing)
                print(check_tangent_vector(M, p, X; atol=atol))
            end
            Test.@test is_tangent_vector(M, p, X; atol=atol)
            Test.@test check_tangent_vector(M, p, X; atol=atol) === nothing
        end
    end

    test_exp_log && Test.@testset "log/exp tests" begin
        epsp1p2 = ManifoldTests.find_eps(pts[1], pts[2])
        atolp1p2 = exp_log_atol_multiplier * epsp1p2
        rtolp1p2 =
            exp_log_atol_multiplier == 0.0 ? sqrt(epsp1p2) * exp_log_rtol_multiplier : 0
        X1 = log(M, pts[1], pts[2])
        X2 = log(M, pts[2], pts[1])
        Test.@test isapprox(M, pts[2], exp(M, pts[1], X1); atol=atolp1p2, rtol=rtolp1p2)
        Test.@test isapprox(M, pts[1], exp(M, pts[1], X1, 0); atol=atolp1p2, rtol=rtolp1p2)
        Test.@test isapprox(M, pts[2], exp(M, pts[1], X1, 1); atol=atolp1p2, rtol=rtolp1p2)
        if VERSION >= v"1.5" && isa(M, Union{Grassmann,GeneralizedStiefel})
            # TODO: investigate why this is so imprecise on newer Julia versions on CI
            Test.@test isapprox(
                M,
                pts[1],
                exp(M, pts[2], X2);
                # yields 5*10^-8 for the usual 10^-13 we impose on earlier Julia versions
                atol=atolp1p2 * 5 * 10^5,
                rtol=rtolp1p2,
            )
        else
            Test.@test isapprox(M, pts[1], exp(M, pts[2], X2); atol=atolp1p2, rtol=rtolp1p2)
        end
        Test.@test is_manifold_point(M, exp(M, pts[1], X1); atol=atolp1p2, rtol=rtolp1p2)
        Test.@test isapprox(M, pts[1], exp(M, pts[1], X1, 0); atol=atolp1p2, rtol=rtolp1p2)
        for p in pts
            epsx = ManifoldTests.find_eps(p)
            Test.@test isapprox(
                M,
                p,
                zero_tangent_vector(M, p),
                log(M, p, p);
                atol=epsx * exp_log_atol_multiplier,
                rtol=exp_log_atol_multiplier == 0.0 ?
                     sqrt(epsx) * exp_log_rtol_multiplier : 0,
            )
            Test.@test isapprox(
                M,
                p,
                zero_tangent_vector(M, p),
                inverse_retract(M, p, p);
                atol=epsx * exp_log_atol_multiplier,
                rtol=exp_log_atol_multiplier == 0.0 ?
                     sqrt(epsx) * exp_log_rtol_multiplier : 0.0,
            )
        end
        atolp1 = exp_log_atol_multiplier * ManifoldTests.find_eps(pts[1])
        if is_mutating
            zero_tangent_vector!(M, X1, pts[1])
        else
            X1 = zero_tangent_vector(M, pts[1])
        end
        Test.@test isapprox(M, pts[1], X1, zero_tangent_vector(M, pts[1]); atol=atolp1)
        if is_mutating
            log!(M, X1, pts[1], pts[2])
        else
            X1 = log(M, pts[1], pts[2])
        end

        Test.@test isapprox(M, exp(M, pts[1], X1, 1), pts[2]; atol=atolp1)
        Test.@test isapprox(M, exp(M, pts[1], X1, 0), pts[1]; atol=atolp1)

        Test.@test distance(M, pts[1], pts[2]) ≈ norm(M, pts[1], X1)

        X3 = log(M, pts[1], pts[3])

        Test.@test inner(M, pts[1], X1, X3) ≈ conj(inner(M, pts[1], X3, X1))
        Test.@test inner(M, pts[1], X1, X1) ≈ real(inner(M, pts[1], X1, X1))

        Test.@test norm(M, pts[1], X1) isa Real
        Test.@test norm(M, pts[1], X1) ≈ sqrt(inner(M, pts[1], X1, X1))
    end

    Test.@testset "(inverse &) retraction tests" begin
        for (p, X) in zip(pts, tv)
            epsx = ManifoldTests.find_eps(p)
            for retr_method in retraction_methods
                Test.@test is_manifold_point(M, retract(M, p, X, retr_method))
                Test.@test isapprox(
                    M,
                    p,
                    retract(M, p, X, 0, retr_method);
                    atol=epsx * retraction_atol_multiplier,
                    rtol=retraction_atol_multiplier == 0 ?
                         sqrt(epsx) * retraction_rtol_multiplier : 0,
                )
                if is_mutating
                    new_pt = allocate(p)
                    retract!(M, new_pt, p, X, retr_method)
                else
                    new_pt = retract(M, p, X, retr_method)
                end
                Test.@test is_manifold_point(M, new_pt)
            end
        end
        for p in pts
            epsx = ManifoldTests.find_eps(p)
            for inv_retr_method in inverse_retraction_methods
                Test.@test isapprox(
                    M,
                    p,
                    zero_tangent_vector(M, p),
                    inverse_retract(M, p, p, inv_retr_method);
                    atol=epsx * retraction_atol_multiplier,
                    rtol=retraction_atol_multiplier == 0 ?
                         sqrt(epsx) * retraction_rtol_multiplier : 0,
                )
            end
        end
    end

    test_vector_spaces && Test.@testset "vector spaces tests" begin
        for p in pts
            X = zero_tangent_vector(M, p)
            mts = Manifolds.VectorBundleFibers(Manifolds.TangentSpace, M)
            Test.@test isapprox(M, p, X, zero_vector(mts, p))
            if is_mutating
                zero_vector!(mts, X, p)
                Test.@test isapprox(M, p, X, zero_tangent_vector(M, p))
            end
        end
    end

    Test.@testset "basic linear algebra in tangent space" begin
        for (p, X) in zip(pts, tv)
            Test.@test isapprox(
                M,
                p,
                0 * X,
                zero_tangent_vector(M, p);
                atol=ManifoldTests.find_eps(pts[1]),
            )
            Test.@test isapprox(M, p, 2 * X, X + X)
            Test.@test isapprox(M, p, 0 * X, X - X)
            Test.@test isapprox(M, p, (-1) * X, -X)
        end
    end

    test_tangent_vector_broadcasting &&
        Test.@testset "broadcasted linear algebra in tangent space" begin
            for (p, X) in zip(pts, tv)
                Test.@test isapprox(M, p, 3 * X, 2 .* X .+ X)
                Test.@test isapprox(M, p, -X, X .- 2 .* X)
                Test.@test isapprox(M, p, -X, .-X)
                if (isa(X, AbstractArray))
                    Y = allocate(X)
                    Y .= 2 .* X .+ X
                else
                    Y = 2 * X + X
                end
                Test.@test isapprox(M, p, Y, 3 * X)
            end
        end

    test_project_tangent && Test.@testset "project tangent test" begin
        for (p, X) in zip(pts, tv)
            atol = ManifoldTests.find_eps(p) * projection_atol_multiplier
            Test.@test isapprox(M, p, X, project(M, p, X); atol=atol)
            if is_mutating
                X2 = allocate(X)
                project!(M, X2, p, X)
            else
                X2 = project(M, p, X)
            end
            Test.@test isapprox(M, p, X2, X; atol=atol)
        end
    end

    test_project_point && Test.@testset "project point test" begin
        for p in pts
            atol = ManifoldTests.find_eps(p) * projection_atol_multiplier
            Test.@test isapprox(M, p, project(M, p); atol=atol)
            if is_mutating
                p2 = allocate(p)
                project!(M, p2, p)
            else
                p2 = project(M, p)
            end
            Test.@test isapprox(M, p2, p; atol=atol)
        end
    end

    !(
        default_retraction_method === nothing ||
        default_inverse_retraction_method === nothing
    ) && Test.@testset "vector transport" begin
        tvatol = is_tangent_atol_multiplier * ManifoldTests.find_eps(pts[1])
        X1 = inverse_retract(M, pts[1], pts[2], default_inverse_retraction_method)
        X2 = inverse_retract(M, pts[1], pts[3], default_inverse_retraction_method)
        pts32 = retract(M, pts[1], X2, default_retraction_method)
        test_default_vector_transport && Test.@testset "default vector transport" begin
            v1t1 = vector_transport_to(M, pts[1], X1, pts32)
            v1t2 = vector_transport_direction(M, pts[1], X1, X2)
            Test.@test is_tangent_vector(M, pts32, v1t1; atol=tvatol)
            Test.@test is_tangent_vector(M, pts32, v1t2; atol=tvatol)
            Test.@test isapprox(M, pts32, v1t1, v1t2)
            Test.@test isapprox(M, pts[1], vector_transport_to(M, pts[1], X1, pts[1]), X1)

            is_mutating && Test.@testset "mutating variants" begin
                v1t1_m = allocate(v1t1)
                v1t2_m = allocate(v1t2)
                vector_transport_to!(M, v1t1_m, pts[1], X1, pts32)
                vector_transport_direction!(M, v1t2_m, pts[1], X1, X2)
                Test.@test isapprox(M, pts32, v1t1, v1t1_m)
                Test.@test isapprox(M, pts32, v1t2, v1t2_m)
            end
        end

        for (vtm, test_to, test_dir, rtr_m, irtr_m) in zip(
            vector_transport_methods,
            test_vector_transport_to,
            test_vector_transport_direction,
            vector_transport_retractions,
            vector_transport_inverse_retractions,
        )
            Test.@testset "vector transport method $(vtm)" begin
                tvatol = is_tangent_atol_multiplier * ManifoldTests.find_eps(pts[1])
                X1 = inverse_retract(M, pts[1], pts[2], irtr_m)
                X2 = inverse_retract(M, pts[1], pts[3], irtr_m)
                pts32 = retract(M, pts[1], X2, rtr_m)
                test_to && (v1t1 = vector_transport_to(M, pts[1], X1, pts32, vtm))
                test_dir && (v1t2 = vector_transport_direction(M, pts[1], X1, X2, vtm))
                test_to &&
                    Test.@test is_tangent_vector(M, pts32, v1t1, true; atol=tvatol)
                test_dir &&
                    Test.@test is_tangent_vector(M, pts32, v1t2, true; atol=tvatol)
                (test_to && test_dir) && Test.@test isapprox(M, pts32, v1t1, v1t2)
                test_to && Test.@test isapprox(
                    M,
                    pts[1],
                    vector_transport_to(M, pts[1], X1, pts[1], vtm),
                    X1,
                )
                test_dir && Test.@test isapprox(
                    M,
                    pts[1],
                    vector_transport_direction(
                        M,
                        pts[1],
                        X1,
                        zero_tangent_vector(M, pts[1]),
                        vtm,
                    ),
                    X1,
                )

                is_mutating && Test.@testset "mutating variants" begin
                    if test_to
                        v1t1_m = allocate(v1t1)
                        vector_transport_to!(M, v1t1_m, pts[1], X1, pts32, vtm)
                        Test.@test isapprox(M, pts32, v1t1, v1t1_m)
                    end
                    if test_dir
                        v1t2_m = allocate(v1t2)
                        vector_transport_direction!(M, v1t2_m, pts[1], X1, X2, vtm)
                        Test.@test isapprox(M, pts32, v1t2, v1t2_m)
                    end
                end
            end
        end
    end

    for btype in basis_types_vecs
        Test.@testset "Basis support for $(btype)" begin
            p = pts[1]
            b = get_basis(M, p, btype)
            Test.@test isa(b, CachedBasis)
            bvectors = get_vectors(M, p, b)
            N = length(bvectors)

            # test orthonormality
            for i in 1:N
                Test.@test norm(M, p, bvectors[i]) ≈ 1
                for j in (i + 1):N
                    Test.@test real(inner(M, p, bvectors[i], bvectors[j])) ≈ 0 atol =
                        sqrt(ManifoldTests.find_eps(p))
                end
            end
            if isa(btype, ProjectedOrthonormalBasis)
                # check projection idempotency
                for i in 1:N
                    Test.@test norm(M, p, bvectors[i]) ≈ 1
                    for j in (i + 1):N
                        Test.@test real(inner(M, p, bvectors[i], bvectors[j])) ≈ 0 atol =
                            sqrt(ManifoldTests.find_eps(p))
                    end
                end
                # check projection idempotency
                for i in 1:N
                    Test.@test isapprox(M, p, project(M, p, bvectors[i]), bvectors[i])
                end
            end
            if !isa(btype, ProjectedOrthonormalBasis) && (
                basis_has_specialized_diagonalizing_get ||
                !isa(btype, DiagonalizingOrthonormalBasis)
            )
                X1 = inverse_retract(M, p, pts[2], default_inverse_retraction_method)
                Xb = get_coordinates(M, p, X1, btype)

                Test.@test get_coordinates(M, p, X1, b) ≈ Xb
                Test.@test isapprox(
                    M,
                    p,
                    get_vector(M, p, Xb, b),
                    get_vector(M, p, Xb, btype),
                )
            end
        end
    end

    for btype in (basis_types_to_from..., basis_types_vecs...)
        p = pts[1]
        N = number_of_coordinates(M, btype)
        if !isa(btype, ProjectedOrthonormalBasis) && (
            basis_has_specialized_diagonalizing_get ||
            !isa(btype, DiagonalizingOrthonormalBasis)
        )
            X1 = inverse_retract(M, p, pts[2], default_inverse_retraction_method)

            Xb = get_coordinates(M, p, X1, btype)
            #Test.@test isa(Xb, AbstractVector{<:Real})
            Test.@test length(Xb) == N
            Xbi = get_vector(M, p, Xb, btype)
            Test.@test isapprox(M, p, X1, Xbi)

            Xs = [[ifelse(i == j, 1, 0) for j in 1:N] for i in 1:N]
            Xs_invs = [get_vector(M, p, Xu, btype) for Xu in Xs]
            # check orthonormality of inverse representation
            for i in 1:N
                Test.@test norm(M, p, Xs_invs[i]) ≈ 1 atol = ManifoldTests.find_eps(p)
                for j in (i + 1):N
                    Test.@test real(inner(M, p, Xs_invs[i], Xs_invs[j])) ≈ 0 atol =
                        sqrt(ManifoldTests.find_eps(p))
                end
            end

            if is_mutating
                Xb_s = allocate(Xb)
                Test.@test get_coordinates!(M, Xb_s, p, X1, btype) === Xb_s
                Test.@test isapprox(Xb_s, Xb; atol=ManifoldTests.find_eps(p))

                Xbi_s = allocate(Xbi)
                Test.@test get_vector!(M, Xbi_s, p, Xb, btype) === Xbi_s
                Test.@test isapprox(M, p, X1, Xbi_s)
            end
        end
    end

    test_vee_hat && Test.@testset "vee and hat" begin
        p = pts[1]
        q = pts[2]
        X = inverse_retract(M, p, q, default_inverse_retraction_method)
        Y = vee(M, p, X)
        Test.@test length(Y) == number_of_coordinates(M, ManifoldsBase.VeeOrthogonalBasis())
        Test.@test isapprox(M, p, X, hat(M, p, Y))
        Y2 = allocate(Y)
        vee_ret = vee!(M, Y2, p, X)
        Test.@test vee_ret === Y2
        Test.@test isapprox(Y, Y2)
        X2 = allocate(X)
        hat_ret = hat!(M, X2, p, Y)
        Test.@test hat_ret === X2
        Test.@test isapprox(M, p, X2, X)
    end

    mid_point12 !== nothing && Test.@testset "midpoint" begin
        epsp1p2 = ManifoldTests.find_eps(pts[1], pts[2])
        atolp1p2 = exp_log_atol_multiplier * epsp1p2
        rtolp1p2 =
            exp_log_atol_multiplier == 0.0 ? sqrt(epsp1p2) * exp_log_rtol_multiplier : 0
        mp = mid_point(M, pts[1], pts[2])
        Test.@test isapprox(M, mp, mid_point12; atol=atolp1p2, rtol=rtolp1p2)
        if is_mutating
            mpm = allocate(mp)
            mid_point!(M, mpm, pts[1], pts[2])
            Test.@test isapprox(M, mpm, mid_point12; atol=atolp1p2, rtol=rtolp1p2)
        end
    end

    test_forward_diff && Test.@testset "ForwardDiff support" begin
        ManifoldTests.test_forwarddiff(M, pts, tv)
    end

    test_reverse_diff && Test.@testset "ReverseDiff support" begin
        ManifoldTests.test_reversediff(M, pts, tv)
    end

    test_musical_isomorphisms && Test.@testset "Musical isomorphisms" begin
        if default_inverse_retraction_method !== nothing
            tv_m = inverse_retract(M, pts[1], pts[2], default_inverse_retraction_method)
        else
            tv_m = zero_tangent_vector(M, pts[1])
        end
        ctv_m = flat(M, pts[1], FVector(TangentSpace, tv_m))
        Test.@test ctv_m.type == CotangentSpace
        tv_m_back = sharp(M, pts[1], ctv_m)
        Test.@test tv_m_back.type == TangentSpace
    end

    Test.@testset "number_eltype" begin
        for (p, X) in zip(pts, tv)
            Test.@test number_eltype(X) == number_eltype(p)
            p = retract(M, p, X, default_retraction_method)
            Test.@test number_eltype(p) == number_eltype(p)
        end
    end

    is_mutating && Test.@testset "copyto!" begin
        for (p, X) in zip(pts, tv)
            p2 = allocate(p)
            copyto!(p2, p)
            Test.@test isapprox(M, p2, p)

            X2 = allocate(X)
            if default_inverse_retraction_method === nothing
                X3 = zero_tangent_vector(M, p)
                copyto!(X2, X3)
                Test.@test isapprox(M, p, X2, zero_tangent_vector(M, p))
            else
                q = retract(M, p, X, default_retraction_method)
                X3 = inverse_retract(M, p, q, default_inverse_retraction_method)
                copyto!(X2, X3)
                Test.@test isapprox(
                    M,
                    p,
                    X2,
                    inverse_retract(M, p, q, default_inverse_retraction_method),
                )
            end
        end
    end

    is_mutating && Test.@testset "point distributions" begin
        for p in pts
            prand = allocate(p)
            for pd in point_distributions
                for _ in 1:10
                    Test.@test is_manifold_point(M, rand(pd))
                    if test_mutating_rand
                        rand!(pd, prand)
                        Test.@test is_manifold_point(M, prand)
                    end
                end
            end
        end
    end

    Test.@testset "tangent vector distributions" begin
        for tvd in tvector_distributions
            supp = Manifolds.support(tvd)
            for _ in 1:10
                randtv = rand(tvd)
                atol = rand_tvector_atol_multiplier * ManifoldTests.find_eps(randtv)
                Test.@test is_tangent_vector(M, supp.point, randtv; atol=atol)
            end
        end
    end
    return nothing
end
