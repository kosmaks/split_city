SPLIT_CITY_GIS_CONFIG = YAML.load_file("#{Rails.root}/config/gis.yml")[Rails.env]
SPLIT_CITY_GIS_CONFIG_prod = YAML.load_file("#{Rails.root}/config/gis.yml")['production']
SPLIT_CITY_GIS_CONFIG_dev = YAML.load_file("#{Rails.root}/config/gis.yml")['development']

