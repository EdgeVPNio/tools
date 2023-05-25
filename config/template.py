BASE_TEMAPLTE = {
    "Broker": {"Overlays": ["_OVERLAYNAME_"]},
    "Signal": {
        "Overlays": {
            "_OVERLAYNAME_": {
                "HostAddress": "A.B.C.D",
                "AuthenticationMethod": "PASSWORD",
                "Port": "5222",
                "Username": "test1@openfire.local",
                "Password": "password_test1",
            }
        }
    },
    "LinkManager": {
        "Stun": ["stun.l.google.com:19302", "stun1.l.google.com:19302"],
        "Overlays": {
            "_OVERLAYNAME_": {
                "IgnoredNetInterfaces": ["flannel.1", "cni0", "docker0", "ovs-system"]
            }
        },
    },
    "BridgeController": {
        "BoundedFlood": {"Overlays": {"_OVERLAYNAME_": {}}},
        "Overlays": {"_OVERLAYNAME_": {}},
    },
}


UPDATES = {
    "Broker": {
        "Overlays": ["PiK8kEG"],
        "NodeId": "",
        "LogLevel": "DEBUG",
    },
    "Signal": {
        "Overlays": {
            "PiK8kEG": {
                "HostAddress": "trial.edgevpn.io",
                "AuthenticationMethod": "PASSWORD",
                "Port": "5222",
                "Username": "PiK8kEG_node9@trial.edgevpn.io",
                "Password": "ztgxxfunbisptvrw",
            }
        }
    },
    "Topology": {
        "StateTracingEnabled": True,
        "Overlays": {"PiK8kEG": {"LocationId": 0, "EncryptionRequired": False}},
    },
    "LinkManager": {
        "Stun": ["stun.l.google.com:19302", "stun1.l.google.com:19302"],
        "Turn": [
            {
                "Address": "trial.edgevpn.io:3478",
                "User": "PiK8kEG_node9",
                "Password": "ztgxxfunbisptvrw",
            }
        ],
        "IgnoredNetInterfaces": [
            "flannel.1",
            "cni0",
            "docker0",
            "nodelocaldns",
            "kube-ipvs0",
            "ovs-system",
            "nebula1",
        ],
    },
    "GeneveTunnel": {"Overlays": {"PiK8kEG": {"EndPointAddress": "*.*.*.*"}}},
    "BridgeController": {
        "BoundedFlood": {
            "LogLevel": "INFO",
            "StateTracingEnabled": True,
            "Overlays": {"PiK8kEG": {}},
        },
        "Overlays": {
            "PiK8kEG": {
                "NetDevice": {
                    "MTU": 1410,
                    "AppBridge": {"MTU": 1350, "NetworkAddress": "10.10.100.0/24"},
                }
            }
        },
    },
    "UsageReport": {
        "Enabled": True,
        "TimerInterval": 3600,
        "WebService": "https://qdscz6pg37.execute-api.us-west-2.amazonaws.com/default/EvioUsageReport",
    },
}

NODE_ID = "a100###ffffffffffffffffffffff###"
