"""Download Bybit data for the USDCUSDT pair."""

import pandas as pd
import datetime as dt

BASE_URL = "https://public.bybit.com/trading"
SYMBOL = "USDCUSDT"

def daterange(start, end):
    day = start
    one = dt.timedelta(days=1)
    while day <= end:
        yield day
        day += one

def get_bybit_data(start, end):
    df = pd.DataFrame()
    for day in daterange(start, end):
        url = f"{BASE_URL}/{SYMBOL}/{SYMBOL}{day:%Y-%m-%d}.csv.gz"
        try:
            new_df = pd.read_csv(url, compression='infer')
            df = pd.concat([df, new_df])
            print(f"Data fetched for {day}: {len(new_df)} rows")
        except Exception as e:
            print(f"Error getting data for {day}: {e}")
    return df

if __name__ == "__main__":
    START_DATE = dt.date(2025, 7, 1)
    END_DATE   = dt.date(2025, 9, 30)
    df = get_bybit_data(START_DATE, END_DATE)
    df.to_csv(f"data/{SYMBOL}.csv", index=False)