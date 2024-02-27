package p2p_signaling

import "core:strings"
import "core:mem"
import "core:time"
import "core:net"
import "core:fmt"
import "core:thread"
import "core:encoding/base64"

running := true
clients: [dynamic]net.TCP_Socket
sources: [dynamic]net.Endpoint

idents: [dynamic][]u8
idents_len: [dynamic]int

run :: proc() {
    buf: [1024 * 3]u8

    for {
        for idx := 0; idx < len(idents_len); idx += 1 {
            client := clients[idx]
            source := sources[idx]

            bytes, err := net.recv_tcp(client, buf[:])
            if err != nil {
                continue
            }

            if bytes == 0 {
                continue
            }

            ident_len := idents_len[idx]

            if (ident_len == 0) {
                i := 0
                for ; i < bytes; i += 1 {
                    if buf[i] == 0 {
                        break
                    }
                }
                idents_len[idx] = i
                mem.copy(&idents[idx][0], &buf[0], i)

                name := strings.string_from_ptr(&idents[idx][0], bytes)

                fmt.printf("%v connected\n", name)
            } else {
                found := false
                i := 0
                for ; i < bytes; i += 1 {
                    if buf[i] == ' ' {
                        found = true
                        break
                    }
                }

                if !found {
                    return
                }

                dest := strings.string_from_ptr(&buf[0], i)
                payload := strings.string_from_ptr(&buf[i + 1], bytes - (i + 1))

                fmt.printf("Source %v is sending payload to %v\n", source, dest)
                cnt := 0
                for id in idents {
                    fmt.printf("Trying %s with length %v, against %s with length %v\n", id[:idents_len[cnt]], idents_len[cnt], buf[:i], i);
                    if idents_len[cnt] == i && mem.compare_byte_ptrs(&buf[0], &id[0], i) == 0 {
                        fmt.printf("Found!\n");
                        net.send_tcp(clients[cnt], transmute([]u8)payload)
                        break
                    }
                    cnt += 1
                }
            }

        }
        time.accurate_sleep(10 * time.Microsecond)
    }
}

main :: proc() {
    ep, ok := net.parse_endpoint("0.0.0.0:10000")
    if !ok {
        fmt.eprintln("Unable to parse endpoint")
        return
    }

    socket, socket_err := net.listen_tcp(ep)
    if socket_err != nil {
        fmt.eprintln("Unable to create socket")
        return
    }

    thread.create_and_start(run)

    for {
        client, source, err := net.accept_tcp(socket)
        if err != nil {
            fmt.eprintln("Accept error")
            return
        }

        net.set_blocking(client, false)

        append(&clients, client)
        append(&sources, source)
        buf := make([]u8, 100)
        append(&idents, buf[:])
        append(&idents_len, 0)
    }
}
