class Module:
    def __init__(self, module_id, filepath, name, params):
        self.module_id = module_id
        self.filepath = filepath
        self.name = name
        self.params = params


class IAI_Config(Module):
    def __init__(self, params):
        super().__init__("industrialai", filepath="./industrialai.bicep", name="iai", params=params)


class RecommenderConfig(Module):
    def __init__(self, params):
        super().__init__("recommender", filepath="./recommender.bicep", name="reco", params=params)


class Create(Module):
    def __init__(self, deploymentName, params):
        super().__init__("deploy_one", filepath="./create.bicep", name=deploymentName, params=params)


def solution(deploymentName: str, location: str, reco: bool = True):
    params = {
        "location": location
    }

    if reco:
        reco_config = RecommenderConfig(params=params)
        create = Create(deploymentName, params={"config": reco_config})
        modules = [reco_config, create]
    else:
        iai_config = IAI_Config(params=params)
        create = Create(deploymentName, params={"config": iai_config})
        modules = [iai_config, create]

    for module in modules:
        print(str(module))
