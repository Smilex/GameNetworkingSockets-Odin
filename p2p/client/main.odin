package p2p_client

import "core:mem"
import "core:net"
import "core:fmt"
import "core:time"
import "core:strings"
import "core:thread"
import "core:runtime"
import "core:encoding/base64"
import "core:c/libc"
import gns "../../"

gns_interface: gns.SocketsPtr
remote_identity: gns.Identity
local_identity: gns.Identity
remote_port : i32 = 43578 
local_port : i32 = 43577
listen_sock: gns.HSteamListenSocket
connection: gns.HSteamNetConnection
custom_signaling: gns.ConnectionSignalingPtr
custom_socket: net.TCP_Socket
custom_runner: bool = true

run :: proc() {
    buf: [1024 * 4]u8
    for custom_runner {
        bytes, err := net.recv_tcp(custom_socket, buf[:])
        if err != nil {
            fmt.printf("err = %v\n", err)
            continue
        }

        if bytes == 0 {
            return
        }

        decoded := base64.decode(strings.string_from_ptr(&buf[0], bytes), allocator = context.temp_allocator)

        gns.ReceivedP2PCustomSignal2(gns_interface, &decoded[0], i32(len(decoded)), nil, custom_on_connect_request, custom_send_rejection_signal)
    }
}

custom_send_signal :: proc(ctx: rawptr, hConn: gns.HSteamNetConnection, info: ^gns.ConnectionInfo, pMsg: rawptr, cbMsg: i32) -> bool {
    a := cast([^]u8)libc.malloc(1024 * 4)
    defer libc.free(a)
    arena: mem.Arena
    mem.arena_init(&arena, a[0:1024 * 4])
    alloc := mem.arena_allocator(&arena)
    msg := strings.string_from_ptr(cast(^u8)pMsg, int(cbMsg))
    base := base64.encode(transmute([]u8)msg, allocator = alloc)
    buf := make([]u8, len(base) + 100, allocator = alloc)

    gns.Identity_ToString(&remote_identity, &buf[0], 100)
    i := 0
    for ; i < 100; i += 1 {
        if buf[i] == 0 {
            break
        }
    }

    if (i == 100) {
        return false
    }

    buf[i] = ' ';
    i += 1

    mem.copy(&buf[i], raw_data(base), len(base))
    i += len(base)

    net.send_tcp(custom_socket, buf[:i])

    return true
}

custom_release :: proc(ctx: rawptr) {
    custom_runner = false
    net.close(custom_socket)
}

custom_on_connect_request :: proc(ctx: rawptr, hConn: gns.HSteamNetConnection, identityPeer: ^gns.Identity, nLocalVirtualPort: i32) -> gns.ConnectionSignalingPtr {
    return gns.CreateCustomSignaling(nil, custom_send_signal, custom_release)
}

custom_send_rejection_signal :: proc(ctx: rawptr, identityPeer: ^gns.Identity, pMsg: rawptr, cbMsg: i32) {
}

custom_connect_to_server :: proc() -> bool {
    socket, socket_err := net.dial_tcp_from_hostname_and_port_string("localhost:10000")
    if socket_err != nil {
        fmt.eprintln("Unable to connect to signaling server")
        return false
    }

    custom_socket = socket

    net.set_blocking(socket, true)

    buf: [100]u8
    gns.Identity_ToString(&local_identity, &buf[0], 100)
    local_identity_str := strings.string_from_ptr(&buf[0], 100)
    msg := fmt.aprintf("%v", local_identity_str);

    net.send(socket, transmute([]u8)msg)

    return true
}

OnSteamNetConnectionStatusChanged :: proc( pInfo: gns.SteamNetConnectionStatusChangedCallback_t )
{
    fmt.println("OnSteamNetConnectionStatusChanged");
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
            fmt.println("Problem");
            if pInfo.m_hConn == connection {
                connection = 0
            }
        }

        case .k_ESteamNetworkingConnectionState_Connecting:
        {
            fmt.printf("Connecting: %s\n", pInfo.m_info.m_szConnectionDescription);
            if listen_sock != 0 && pInfo.m_info.m_hListenSocket == listen_sock {
                connection = pInfo.m_hConn
                if gns.AcceptConnection(gns_interface, pInfo.m_hConn) != .k_EResultOK {
                    gns.CloseConnection(gns_interface, pInfo.m_hConn, 0, nil, false)
                    fmt.eprintln("Failed to accept connection");
                    return
                }
            }
        }

        case .k_ESteamNetworkingConnectionState_Connected:
            fmt.println("Connected");
    }
}

debug_output :: proc(nType: gns.ESocketsDebugOutputType, pszMsg: cstring) {
    fmt.printf("debug_output: %s\n", pszMsg)
}

main :: proc() {
    gns.Identity_ParseString(&local_identity, size_of(local_identity), "ip:127.0.0.1:1")
    err_msg: gns.DatagramErrMsg
    if !gns.Init(&local_identity, err_msg) {
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

    gns.Utils_SetGlobalConfigValueString(utils, .k_ESteamNetworkingConfig_P2P_STUN_ServerList, "172.217.220.127:19302")
    gns.Utils_SetGlobalConfigValueInt32(utils, .k_ESteamNetworkingConfig_P2P_Transport_ICE_Enable, gns.k_nSteamNetworkingConfig_P2P_Transport_ICE_Enable_All );

    gns.Utils_SetGlobalCallback_SteamNetConnectionStatusChanged(utils, OnSteamNetConnectionStatusChanged)

    gns.Utils_SetGlobalConfigValueInt32(utils, .k_ESteamNetworkingConfig_LogLevel_P2PRendezvous, i32(gns.ESocketsDebugOutputType.k_ESteamNetworkingSocketsDebugOutputType_Msg))

    opt: gns.ConfigValue
    opt.m_eValue = .k_ESteamNetworkingConfig_SymmetricConnect
    opt.m_eDataType = .k_ESteamNetworkingConfig_Int32
    opt.m_val.m_int32 = 1

    options := [?]gns.ConfigValue{opt}
    //listen_sock = gns.CreateListenSocketP2P(gns_interface, local_port, 1, raw_data(options[:]))

    gns.GetIdentity(gns_interface, &local_identity)
    buf: [100]u8
    gns.Identity_ToString(&local_identity, &buf[0], 100)
    local_identity_str := strings.string_from_ptr(&buf[0], 100)

    fmt.printf("Local identity: %v\n", local_identity_str)

    if !custom_connect_to_server() {
        return
    }

    thread.create_and_start(run)

    gns.Identity_ParseString(&remote_identity, size_of(remote_identity), "ip:127.0.0.1:2")

    custom_signaling = gns.CreateCustomSignaling(nil, custom_send_signal, custom_release)
    connection = gns.ConnectP2PCustomSignaling(gns_interface, custom_signaling, &remote_identity, remote_port, 1, raw_data(options[:]))
    for {
        gns.RunCallbacks(gns_interface)

        if connection != 0 {
            msg := "Hello, world!"
            gns.SendMessageToConnection(gns_interface, connection, raw_data(msg), u32(len(msg)), gns.k_nSteamNetworkingSend_Reliable, nil)
        }

        time.accurate_sleep(10 * time.Millisecond)
    }
}
