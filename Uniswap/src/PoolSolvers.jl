module PoolSolvers
    using ModelingToolkit, NonlinearSolve 
    using Symbolics

    export UniswapV2PoolState, UniswapV2PoolPriceUpdate, UniswapV2PoolPositionState, UniswapV2PoolValues, UniswapV2PoolFinances

    export v2Invariant, marginalPrice, swapInvariant

    @syms token0::Real token1::Real liquidity::Real swapAmount0::Real swapAmount1::Real
    v2Invariant = liquidity^2 ~ token0 * token1
    marginalPrice = token1 / token0
    swapInvariant = liquidity^2 ~ (token0 + swapAmount0) * (token1 + swapAmount1)

    abstract type UniswapPoolState end
    abstract type UniswapPoolPositionState end

    struct UniswapV2PoolState <: UniswapPoolState
        amountDollar::Real
        amountToken::Real
    end

    struct UniswapV2PoolPositionState <: UniswapPoolPositionState
        amountDollar::Real
        amountToken::Real
    end

    struct UniswapV2PoolValues
        price::Real
        tvl::Real
    end

    """
    Compute position state given value and a Uniswap V2 pool state.
    """
    function UniswapV2PoolPositionState(pool::UniswapV2PoolState, value::Real)::UniswapV2PoolPositionState
        pool_value = UniswapV2PoolFinances(pool).tvl
        ratio = value / pool_value
        return UniswapV2PoolPositionState(ratio * pool.amountDollar, ratio * pool.amountToken)
    end

    """
    Get the current price of a Uniswap V2 pool.
    """
    function UniswapV2PoolFinances(state::UniswapV2PoolState)::UniswapV2PoolValues
        price = state.amountDollar / state.amountToken
        tvl = state.amountDollar + price * state.amountToken
        return UniswapV2PoolValues(price, tvl)
    end

    """
    Update a Uniswap V2 pool state to a specified new price.
    """
    function UniswapV2PoolPriceUpdate(state::UniswapV2PoolState, targetPrice::Real)::UniswapV2PoolState
        @variables amount_token, amount_dollar
        @parameters pool_constant, target_price
        eqs = [
            pool_constant ~ amount_dollar * amount_token
            target_price ~ amount_dollar / amount_token
        ]
        current_constant = state.amountToken * state.amountDollar
        eqs_sub = substitute(eqs, Dict(pool_constant => current_constant, target_price => targetPrice))
        @named system = NonlinearSystem(eqs_sub,[amount_dollar, amount_token], [])
        smpl_system = structural_simplify(system)
        initial_state = [
            amount_dollar => state.amountDollar, amount_token => state.amountToken
        ]
        prob = NonlinearProblem(smpl_system, initial_state)
        sol = solve(prob, NewtonRaphson())
        newAmountDollar = sol[amount_dollar]
        newAmountToken = sol[amount_token]

        return UniswapV2PoolState(newAmountDollar, newAmountToken)
    end

end