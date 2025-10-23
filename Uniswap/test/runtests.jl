using Test
include("../src/PoolSolvers.jl")

@testset "Uniswap" begin
    @testset "PoolSolvers" begin
        amount_dollar::Real = 18500000
        amount_token::Real = 4900
        pool = PoolSolvers.UniswapV2PoolState(amount_dollar, amount_token)
        @testset "UniswapV2PoolPositionState" begin
            @testset "Scenario 1" begin
                expected_position_value = 100
                position = PoolSolvers.UniswapV2PoolPositionState(pool, expected_position_value)
                expected_dollar = 50 
                expected_token = 0.01324
                expected_price = pool.amountDollar / pool.amountToken
                @test position.amountDollar ≈ expected_dollar atol=1e-3
                @test position.amountToken ≈ expected_token atol=1e-2
                out_value = position.amountDollar + position.amountToken * expected_price
                @test expected_position_value ≈ out_value atol=1e-5
            end
        end
        @testset "UniswapV2PoolFinances" begin
            pool = PoolSolvers.UniswapV2PoolState(amount_dollar, amount_token)
            @testset "Scenario 1" begin
                expected_price = 3775.51
                expected_tvl = 3.700e7
                finances = PoolSolvers.UniswapV2PoolFinances(pool)
                @test finances.price ≈ expected_price atol=1e-1
                @test finances.tvl ≈ expected_tvl atol=1e-4
            end
        end
        @testset "UniswapV2PoolPriceUpdate" begin
            @testset "Scenario 1" begin
                target_price = 3500
                expected_dollar = 1.781e7
                expected_token = 5089.204 
            
                new_state = PoolSolvers.UniswapV2PoolPriceUpdate(pool, target_price)
                @test new_state.amountDollar ≈ expected_dollar rtol=1e-3
                @test new_state.amountToken ≈ expected_token rtol=1e-3
            end
        end
    end
end