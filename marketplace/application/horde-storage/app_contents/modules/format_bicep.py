#  ---------------------------------------------------------------------------------------------------------------
#  Copyright (c) Microsoft Corporation. All rights reserved.
#  ---------------------------------------------------------------------------------------------------------------
"""
Formatter for Bicep Files. Aligns lines by column

Before
------------------------------------------------------------------------------------------------------------------
param config object
module vnet 'network/virtualNetworks.bicep' = if (config.enable.vNET) {
  name: config.resources.vNetName
  params: {
    config: config
  }
}

After
------------------------------------------------------------------------------------------------------------------
module vnet           'network/virtualNetworks.bicep'                     = if (config.enable.vNET) {
  name:                 config.resources.vNetName
  params: {
    config:             config
  }
}

"""
import sys
from secrets import compare_digest


def format(bicep_template):
    with open(bicep_template) as f:
        lines = f.readlines()
        token_counts = {}
        for line in lines:
            tokens = line.split()
            i = 0
            for token in tokens:
                high_count = token_counts.get(i, 0)
                if len(token) > high_count and ("param" or "var" or "resource" or "module" or "output") in line:
                    token_counts[i] = len(token)
                i += 1

        print(token_counts)
        new_file = []
        for line in lines:
            new_line = line
            if line.startswith("var" or "resource" or "module"):
                new_line = ""
                tokens = line.split()
                i = 0
                before_equal = True
                for token in tokens:
                    if compare_digest(token, "="):
                        before_equal = False
                    new_line += token
                    new_line += " "
                    for j in range(1 + (token_counts.get(i, 0) - len(token))):
                        if before_equal:
                            new_line += " "
                    i += 1
                new_line += "\n"
            elif (":" in line) and ": {" not in line and ": [" not in line:
                splits = line.split(":")
                new_line = splits[0] + ": "
                for j in range(
                    2
                    + token_counts[0]
                    + token_counts[1]
                    + token_counts[2]
                    + token_counts.get(3, 0)
                    + token_counts.get(4, 0)
                    - len(splits[0])
                ):
                    new_line += " "
                new_line += splits[1]
                if len(splits) > 2:
                    new_line += ":" + splits[2]
            if line.startswith("var") or line.startswith("output"):
                tokens = line.split("=")
                new_line = tokens[0]
                for j in range(
                    token_counts[0]
                    + token_counts[1]
                    + token_counts[2]
                    + token_counts.get(3, 0)
                    + token_counts.get(4, 0)
                    - len(tokens[0])
                ):
                    new_line += " "

                new_line += "= " + tokens[1]

            new_file.append(new_line)

        with open(bicep_template.replace("bicep", "temp.bicep"), "w") as file:
            for items in new_file:
                file.writelines(items)


if __name__ == "__main__":
    format(sys.argv[1])
