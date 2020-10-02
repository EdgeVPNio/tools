import stat

import git
import os
import sys
sys.path.append('../')
from scripts.tool_config import MAPPING as mapping
from os import path


class Link:
    sym_link = "./ev-tools.sh"
    def __init__(self):
        self.evio_repo = None
        self.tools_repo = None
        self.dir_path = None
        self.dir_path_tools = None

    @staticmethod
    def sync_branch(self):
        """
        Syncing the correct script with EVT script if there is no version given by user.
        """
        self.get_repository()
        try:
            if mapping.get(str(self.evio_repo.active_branch)) is not None and \
                    mapping.get(str(self.evio_repo.active_branch)).get(
                        str(self.evio_repo.active_branch.commit)) is not None:
                file_to_link = mapping[str(self.evio_repo.active_branch)][""]
            elif mapping[str(self.evio_repo.active_branch)] is not None:
                file_to_link = mapping[str(self.evio_repo.active_branch)]["default"]
        except KeyError:
            file_to_link = mapping["default"]
        if path.exists(Link.sym_link):
            os.remove(Link.sym_link)
        os.symlink("./scripts/" + file_to_link, Link.sym_link)
        os.chmod("./scripts/" + file_to_link, 0o775)

    def sync(self, version):
        """
        Syncing the correct script with EVT script if there is a version given by user.
        """
        if version is None:
            self.sync_branch(self)
        else:
            self.get_repository()
            if mapping.get(version).get(str(self.evio_repo.tags[0].commit)) is not None:
                file_to_link = mapping[str(self.evio_repo.active_branch)][self.evio_repo.tags[0].commit]
            else:
                file_to_link = mapping[version]["default"]

    def get_repository(self):
        """
        Get the active branch name of the Evio and Tools repo.
        """
        present_dir = os.getcwd()[0:3]
        for root, subdirs, files in os.walk(present_dir):
            for d in subdirs:
                if d == "evio":
                    self.dir_path = os.path.join(root, d)

        self.evio_repo = git.Repo(self.dir_path)
        #print("Evio Branch name:" + str(self.evio_repo.active_branch))
        for root, subdirs, files in os.walk(present_dir):
            for d in subdirs:
                if d == "tools":
                    self.dir_path_tools = os.path.join(root, d)
        self.tools_repo = git.Repo(self.dir_path_tools)
        #print("Tools Branch name:" + str(self.tools_repo.active_branch))

    def main(self):
        self.sync("20.7.2")


if __name__ == "__main__":
    link = Link()
    link.main()
