package test_server

import "core:fmt"
import "core:time"
import "core:strings"
import gns "../gamenetworkingsockets"

gns_interface: gns.SocketsPtr
poll_group: gns.HSteamNetPollGroup

OnSteamNetConnectionStatusChanged :: proc( pInfo: gns.SteamNetConnectionStatusChangedCallback_t )
{
    // What's the state of the connection?
    #partial switch ( pInfo.m_info.m_eState )
    {
        case .k_ESteamNetworkingConnectionState_None:
            // NOTE: We will get callbacks here when we destroy connections.  You can ignore these.
        case .k_ESteamNetworkingConnectionState_ProblemDetectedLocally, .k_ESteamNetworkingConnectionState_ClosedByPeer:
        {
            // Ignore if they were not previously connected.  (If they disconnected
            // before we accepted the connection.)
            if ( pInfo.m_eOldState == .k_ESteamNetworkingConnectionState_Connected )
            {

            }
            else
            {
            }

            gns.CloseConnection(gns_interface, pInfo.m_hConn, 0, nil, false)
        }

        case .k_ESteamNetworkingConnectionState_Connecting:
        {
            fmt.printf("Connection request from %s\n", pInfo.m_info.m_szConnectionDescription)

            if gns.AcceptConnection(gns_interface, pInfo.m_hConn) != .k_EResultOK {
                gns.CloseConnection(gns_interface, pInfo.m_hConn, 0, nil, false)
                fmt.eprintln("Failed to accept connection");
                return
            }

            if !gns.SetConnectionPollGroup(gns_interface, pInfo.m_hConn, poll_group) {
                gns.CloseConnection(gns_interface, pInfo.m_hConn, 0, nil, false)
                fmt.eprintln("Failed to add to poll group");
                return
            }
        }

        case .k_ESteamNetworkingConnectionState_Connected:
            // We will get a callback immediately after accepting the connection.
            // Since we are the server, we can ignore this, it's not news to us.
    }
}

debug_output :: proc(nType: gns.ESocketsDebugOutputType, pszMsg: cstring) {
    fmt.printf("debug_output: %s\n", pszMsg)
}

main :: proc() {
    err_msg: gns.DatagramErrMsg
    if !gns.Init(nil, err_msg) {
        fmt.eprintln("Unable to init GameNetworkingSockets")
        return
    }
    gns_interface = gns.v009()
    if gns_interface == nil {
        fmt.eprintln("Unable to open GameNetworkingSockets interface")
        return
    }

    utils := gns.Utils_v003()

    gns.Utils_SetDebugOutputFunction(utils, .k_ESteamNetworkingSocketsDebugOutputType_Verbose, debug_output)

    addr: gns.IPAddr;
    gns.IPAddr_Clear(&addr)
    addr.m_port = 14544

    opt: gns.ConfigValue
    opt.m_eValue = .k_ESteamNetworkingConfig_Callback_ConnectionStatusChanged
    opt.m_eDataType = .k_ESteamNetworkingConfig_Ptr
    opt.m_val.m_ptr = rawptr(OnSteamNetConnectionStatusChanged)

    options := [?]gns.ConfigValue{opt}

    listen_socket := gns.CreateListenSocketIP(gns_interface, &addr, 1, raw_data(options[:]))
    if listen_socket == 0 {
        fmt.eprintln("listen socket failed")
        return
    }

    poll_group = gns.CreatePollGroup(gns_interface)

    for {
        incoming_msgs: [1]^gns.Message;
        num_msgs := gns.ReceiveMessagesOnPollGroup(gns_interface, poll_group, raw_data(incoming_msgs[:]), 1)
        if (num_msgs < 0) {
            break
        }
        if (num_msgs > 0) {
            msg := strings.string_from_ptr((^u8)(incoming_msgs[0].m_pData), int(incoming_msgs[0].m_cbSize))
            fmt.printf("%s\n", msg)
            gns.Release(incoming_msgs[0])
        }
        gns.RunCallbacks(gns_interface)

        time.accurate_sleep(10 * time.Millisecond)
    }
}
