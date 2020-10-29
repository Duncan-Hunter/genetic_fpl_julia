import pandas as pd
import requests

if __name__ == "__main__":
    url = 'https://fantasy.premierleague.com/api/bootstrap-static/'
    r = requests.get(url)
    json = r.json()
    json.keys()
    elements_df = pd.DataFrame(json['elements'])
    elements_types_df = pd.DataFrame(json['element_types'])
    teams_df = pd.DataFrame(json['teams'])
    cols = ['first_name', 'second_name', 'team', 'team_code', 'id', 'element_type','now_cost', 'points_per_game', 'total_points', 'form', 'ep_next', 'ep_this']
    slim_df = elements_df[cols]
    slim_df.loc[:, "now_cost"] = slim_df.loc[:, "now_cost"] / 10.
    slim_df.to_csv("./fpl_data.csv", index=False)

