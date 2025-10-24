"""Process Bybit and Uniswap data for the USDCUSDT pair and generate a merged CSV file.

Run this script from the root directory of the project using:

`poetry run python utils/BybitUniswapProcess.py`
"""

import pandas as pd
import numpy as np

def agg_bybit(df: pd.DataFrame, band=0.001) -> pd.DataFrame:
    df = df.copy()

    # timestamp conversion
    s = pd.to_numeric(df['timestamp'], errors='coerce')
    s_ms = np.where(s > 1.0e12, s, s * 1000.0)
    df['time'] = pd.to_datetime(s_ms, unit='ms', utc=True).floor('H')

    # compute signed USDC amount
    base_amt = df.get('size')
    df['amountUSDC'] = np.where(df['side'].str.lower() == 'buy', base_amt, -base_amt)

    # out of band and value
    df['out_of_band'] = (df['price'] > 1 + band) | (df['price'] < 1 - band)
    df['value'] = df['price'] * df['amountUSDC'].abs()


    df['value_out_of_band'] = df['value'].where(df['out_of_band'], 0)

    agg = (
        df.groupby('time', as_index=True)
        .agg(
            bybit_volume=('value', 'sum'),
            out_of_band_value=('value_out_of_band', 'sum'),
            bybit_min_price=('price', 'min'),
            bybit_max_price=('price', 'max')
        )
    )

    # fill in missing hours with zeros
    full_idx = pd.date_range(df['time'].min(), df['time'].max(), freq='H', tz='UTC')
    agg = agg.reindex(full_idx)
    agg['bybit_volume'] = agg['out_of_band_value'].fillna(0.0)
    agg = agg.rename_axis('time').reset_index()
    return agg

    

if __name__ == "__main__":
    # Bybit aggregation
    bybit_raw = pd.read_csv("data/Bybit-raw-USDCUSDT.csv")
    bybit = agg_bybit(bybit_raw, band=0.001)
    bybit.to_csv("data/Bybit-bybit.csv", index=False)
    bybit = bybit[["time","bybit_volume","bybit_min_price","bybit_max_price"]]
    bybit['time'] = pd.to_datetime(bybit['time'], format='%Y-%m-%d %H:%M:%S.%f')

    # Uniswap aggregation
    uniswap = pd.read_csv("data/Uniswap-hourly.csv")
    uniswap['uniswap_volume'] = uniswap['out_of_band_value']
    uniswap['uniswap_volume'] = uniswap['uniswap_volume'].fillna(0.0)
    uniswap = uniswap[["time","uniswap_min_price","uniswap_max_price","uniswap_volume"]]
    uniswap['time'] = pd.to_datetime(uniswap['time'].str.replace(' UTC', '', regex=False), utc=True)  

    # Merge bybit and uniswap
    merged = bybit.merge(uniswap, on='time', how='left')
    merged[[
        "time",
        "uniswap_volume",
        "bybit_volume",
        "uniswap_min_price",
        "uniswap_max_price",
        "bybit_min_price",
        "bybit_max_price"
    ]].to_csv("data/merged.csv", index=False)
