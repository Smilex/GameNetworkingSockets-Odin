package test_client

import "core:fmt"
import "core:time"
import "core:strings"
import gns "../"

gns_interface: gns.SocketsPtr;

OnSteamNetConnectionStatusChanged :: proc( pInfo: gns.SteamNetConnectionStatusChangedCallback_t )
{
    // What's the state of the connection?
    #partial switch ( pInfo.m_info.m_eState )
    {
        case .k_ESteamNetworkingConnectionState_None:
            // NOTE: We will get callbacks here when we destroy connections.  You can ignore these.
        
        case .k_ESteamNetworkingConnectionState_ProblemDetectedLocally, .k_ESteamNetworkingConnectionState_ClosedByPeer:
        {
        // Print an appropriate message
				if ( pInfo.m_eOldState == .k_ESteamNetworkingConnectionState_Connecting )
				{
					// Note: we could distinguish between a timeout, a rejected connection,
					// or some other transport problem.
					fmt.eprintf( "We sought the remote host, yet our efforts were met with defeat.  (%s)", pInfo.m_info.m_szEndDebug );
				}
				else if ( pInfo.m_info.m_eState == .k_ESteamNetworkingConnectionState_ProblemDetectedLocally )
				{
					fmt.eprintf( "Alas, troubles beset us; we have lost contact with the host.  (%s)", pInfo.m_info.m_szEndDebug );
				}
				else
				{
					// NOTE: We could check the reason code for a normal disconnection
					fmt.eprintf( "The host hath bidden us farewell.  (%s)", pInfo.m_info.m_szEndDebug );
				}

				// Clean up the connection.  This is important!
				// The connection is "closed" in the network sense, but
				// it has not been destroyed.  We must close it on our end, too
				// to finish up.  The reason information do not matter in this case,
				// and we cannot linger because it's already closed on the other end,
				// so we just pass 0's.
				//m_pInterface->CloseConnection( pInfo->m_hConn, 0, nullptr, false );
				//m_hConnection = k_HSteamNetConnection_Invalid;
        }

        case .k_ESteamNetworkingConnectionState_Connecting:
            fmt.eprintln("Connecting");

        case .k_ESteamNetworkingConnectionState_Connected:
            fmt.eprintln("Connected!");
    }
}

debug_output :: proc(nType: gns.ESocketsDebugOutputType, pszMsg: cstring) {
    fmt.eprintf("debug_output: %s\n", pszMsg)
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
    if utils == nil {
        fmt.eprintln("Unable to open GameNetworkingSockets utils")
        return
    }
    gns.Utils_SetDebugOutputFunction(utils, .k_ESteamNetworkingSocketsDebugOutputType_Verbose, debug_output)

    addr: gns.IPAddr;
    gns.IPAddr_ParseString(&addr, "127.0.0.1:14544")

    opt: gns.ConfigValue
    opt.m_eValue = .k_ESteamNetworkingConfig_Callback_ConnectionStatusChanged
    opt.m_eDataType = .k_ESteamNetworkingConfig_Ptr
    opt.m_val.m_ptr = rawptr(OnSteamNetConnectionStatusChanged)

    options := [?]gns.ConfigValue{opt}

    socket := gns.ConnectByIPAddress(gns_interface, &addr, 1, raw_data(options[:]))
    if socket == gns.k_HSteamNetConnection_Invalid {
        fmt.eprintln("listen socket failed")
        return
    }

    for {
        msg := "Hello, world!"
        gns.SendMessageToConnection(gns_interface, socket, raw_data(msg), u32(len(msg)), gns.k_nSteamNetworkingSend_Reliable, nil)
        gns.RunCallbacks(gns_interface)

        time.accurate_sleep(100 * time.Millisecond)
    }
}
