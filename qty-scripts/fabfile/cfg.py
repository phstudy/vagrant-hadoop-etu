from ConfigParser import SafeConfigParser

def load_config():
    parser = SafeConfigParser()
    parser.read('config.ini')
    cfg = {}
    cfg['nn1']=[parser.get('nn', 'nn1')]
    cfg['nn2']=[parser.get('nn', 'nn2')]
    return cfg


if __name__ == "__main__":
    print load_config()
