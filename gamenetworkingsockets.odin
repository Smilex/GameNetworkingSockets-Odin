package gamenetworkingsockets

import "core:c/libc"

k_cchSteamNetworkingMaxConnectionCloseReason :: 128
k_cchSteamNetworkingMaxConnectionDescription :: 128
k_cchMaxSteamNetworkingErrMsg :: 1024
k_cchMaxString :: 48
k_HSteamNetConnection_Invalid :: 0
k_cbMaxSteamNetworkingSocketsMessageSizeSend :: 512 * 1024

k_nSteamNetworkingConfig_P2P_Transport_ICE_Enable_Default :: -1; // Special value - use user defaults
k_nSteamNetworkingConfig_P2P_Transport_ICE_Enable_Disable :: 0; // Do not do any ICE work at all or share any IP addresses with peer
k_nSteamNetworkingConfig_P2P_Transport_ICE_Enable_Relay :: 1; // Relayed connection via TURN server.
k_nSteamNetworkingConfig_P2P_Transport_ICE_Enable_Private :: 2; // host addresses that appear to be link-local or RFC1918 addresses
k_nSteamNetworkingConfig_P2P_Transport_ICE_Enable_Public :: 4; // STUN reflexive addresses, or host address that isn't a "private" address
k_nSteamNetworkingConfig_P2P_Transport_ICE_Enable_All :: 0x7fffffff;

k_nSteamNetworkingSend_Unreliable :: 0
k_nSteamNetworkingSend_NoNagle :: 1
k_nSteamNetworkingSend_UnreliableNoNagle :: k_nSteamNetworkingSend_Unreliable|k_nSteamNetworkingSend_NoNagle
k_nSteamNetworkingSend_NoDelay :: 4
k_nSteamNetworkingSend_UnreliableNoDelay :: k_nSteamNetworkingSend_Unreliable|k_nSteamNetworkingSend_NoDelay|k_nSteamNetworkingSend_NoNagle
k_nSteamNetworkingSend_Reliable :: 8
k_nSteamNetworkingSend_ReliableNoNagle :: k_nSteamNetworkingSend_Reliable|k_nSteamNetworkingSend_NoNagle
k_nSteamNetworkingSend_UseCurrentThread :: 16
k_nSteamNetworkingSend_AutoRestartBrokenSession :: 32

SocketsPtr :: distinct rawptr
UtilsPtr :: distinct rawptr
ConnectionSignalingPtr :: distinct rawptr
HSteamListenSocket :: distinct libc.uint
HSteamNetConnection :: distinct libc.uint
HSteamNetPollGroup :: distinct libc.uint
POPID :: distinct libc.uint
Microseconds :: distinct i64
ErrMsg :: [k_cchMaxSteamNetworkingErrMsg]libc.char
DatagramErrMsg :: distinct ErrMsg

// General result codes
EResult :: enum libc.int
{
	k_EResultNone = 0,							// no result
	k_EResultOK	= 1,							// success
	k_EResultFail = 2,							// generic failure 
	k_EResultNoConnection = 3,					// no/failed network connection
//	k_EResultNoConnectionRetry = 4,				// OBSOLETE - removed
	k_EResultInvalidPassword = 5,				// password/ticket is invalid
	k_EResultLoggedInElsewhere = 6,				// same user logged in elsewhere
	k_EResultInvalidProtocolVer = 7,			// protocol version is incorrect
	k_EResultInvalidParam = 8,					// a parameter is incorrect
	k_EResultFileNotFound = 9,					// file was not found
	k_EResultBusy = 10,							// called method busy - action not taken
	k_EResultInvalidState = 11,					// called object was in an invalid state
	k_EResultInvalidName = 12,					// name is invalid
	k_EResultInvalidEmail = 13,					// email is invalid
	k_EResultDuplicateName = 14,				// name is not unique
	k_EResultAccessDenied = 15,					// access is denied
	k_EResultTimeout = 16,						// operation timed out
	k_EResultBanned = 17,						// VAC2 banned
	k_EResultAccountNotFound = 18,				// account not found
	k_EResultInvalidSteamID = 19,				// steamID is invalid
	k_EResultServiceUnavailable = 20,			// The requested service is currently unavailable
	k_EResultNotLoggedOn = 21,					// The user is not logged on
	k_EResultPending = 22,						// Request is pending (may be in process, or waiting on third party)
	k_EResultEncryptionFailure = 23,			// Encryption or Decryption failed
	k_EResultInsufficientPrivilege = 24,		// Insufficient privilege
	k_EResultLimitExceeded = 25,				// Too much of a good thing
	k_EResultRevoked = 26,						// Access has been revoked (used for revoked guest passes)
	k_EResultExpired = 27,						// License/Guest pass the user is trying to access is expired
	k_EResultAlreadyRedeemed = 28,				// Guest pass has already been redeemed by account, cannot be acked again
	k_EResultDuplicateRequest = 29,				// The request is a duplicate and the action has already occurred in the past, ignored this time
	k_EResultAlreadyOwned = 30,					// All the games in this guest pass redemption request are already owned by the user
	k_EResultIPNotFound = 31,					// IP address not found
	k_EResultPersistFailed = 32,				// failed to write change to the data store
	k_EResultLockingFailed = 33,				// failed to acquire access lock for this operation
	k_EResultLogonSessionReplaced = 34,
	k_EResultConnectFailed = 35,
	k_EResultHandshakeFailed = 36,
	k_EResultIOFailure = 37,
	k_EResultRemoteDisconnect = 38,
	k_EResultShoppingCartNotFound = 39,			// failed to find the shopping cart requested
	k_EResultBlocked = 40,						// a user didn't allow it
	k_EResultIgnored = 41,						// target is ignoring sender
	k_EResultNoMatch = 42,						// nothing matching the request found
	k_EResultAccountDisabled = 43,
	k_EResultServiceReadOnly = 44,				// this service is not accepting content changes right now
	k_EResultAccountNotFeatured = 45,			// account doesn't have value, so this feature isn't available
	k_EResultAdministratorOK = 46,				// allowed to take this action, but only because requester is admin
	k_EResultContentVersion = 47,				// A Version mismatch in content transmitted within the Steam protocol.
	k_EResultTryAnotherCM = 48,					// The current CM can't service the user making a request, user should try another.
	k_EResultPasswordRequiredToKickSession = 49,// You are already logged in elsewhere, this cached credential login has failed.
	k_EResultAlreadyLoggedInElsewhere = 50,		// You are already logged in elsewhere, you must wait
	k_EResultSuspended = 51,					// Long running operation (content download) suspended/paused
	k_EResultCancelled = 52,					// Operation canceled (typically by user: content download)
	k_EResultDataCorruption = 53,				// Operation canceled because data is ill formed or unrecoverable
	k_EResultDiskFull = 54,						// Operation canceled - not enough disk space.
	k_EResultRemoteCallFailed = 55,				// an remote call or IPC call failed
	k_EResultPasswordUnset = 56,				// Password could not be verified as it's unset server side
	k_EResultExternalAccountUnlinked = 57,		// External account (PSN, Facebook...) is not linked to a Steam account
	k_EResultPSNTicketInvalid = 58,				// PSN ticket was invalid
	k_EResultExternalAccountAlreadyLinked = 59,	// External account (PSN, Facebook...) is already linked to some other account, must explicitly request to replace/delete the link first
	k_EResultRemoteFileConflict = 60,			// The sync cannot resume due to a conflict between the local and remote files
	k_EResultIllegalPassword = 61,				// The requested new password is not legal
	k_EResultSameAsPreviousValue = 62,			// new value is the same as the old one ( secret question and answer )
	k_EResultAccountLogonDenied = 63,			// account login denied due to 2nd factor authentication failure
	k_EResultCannotUseOldPassword = 64,			// The requested new password is not legal
	k_EResultInvalidLoginAuthCode = 65,			// account login denied due to auth code invalid
	k_EResultAccountLogonDeniedNoMail = 66,		// account login denied due to 2nd factor auth failure - and no mail has been sent
	k_EResultHardwareNotCapableOfIPT = 67,		// 
	k_EResultIPTInitError = 68,					// 
	k_EResultParentalControlRestricted = 69,	// operation failed due to parental control restrictions for current user
	k_EResultFacebookQueryError = 70,			// Facebook query returned an error
	k_EResultExpiredLoginAuthCode = 71,			// account login denied due to auth code expired
	k_EResultIPLoginRestrictionFailed = 72,
	k_EResultAccountLockedDown = 73,
	k_EResultAccountLogonDeniedVerifiedEmailRequired = 74,
	k_EResultNoMatchingURL = 75,
	k_EResultBadResponse = 76,					// parse failure, missing field, etc.
	k_EResultRequirePasswordReEntry = 77,		// The user cannot complete the action until they re-enter their password
	k_EResultValueOutOfRange = 78,				// the value entered is outside the acceptable range
	k_EResultUnexpectedError = 79,				// something happened that we didn't expect to ever happen
	k_EResultDisabled = 80,						// The requested service has been configured to be unavailable
	k_EResultInvalidCEGSubmission = 81,			// The set of files submitted to the CEG server are not valid !
	k_EResultRestrictedDevice = 82,				// The device being used is not allowed to perform this action
	k_EResultRegionLocked = 83,					// The action could not be complete because it is region restricted
	k_EResultRateLimitExceeded = 84,			// Temporary rate limit exceeded, try again later, different from k_EResultLimitExceeded which may be permanent
	k_EResultAccountLoginDeniedNeedTwoFactor = 85,	// Need two-factor code to login
	k_EResultItemDeleted = 86,					// The thing we're trying to access has been deleted
	k_EResultAccountLoginDeniedThrottle = 87,	// login attempt failed, try to throttle response to possible attacker
	k_EResultTwoFactorCodeMismatch = 88,		// two factor code mismatch
	k_EResultTwoFactorActivationCodeMismatch = 89,	// activation code for two-factor didn't match
	k_EResultAccountAssociatedToMultiplePartners = 90,	// account has been associated with multiple partners
	k_EResultNotModified = 91,					// data not modified
	k_EResultNoMobileDevice = 92,				// the account does not have a mobile device associated with it
	k_EResultTimeNotSynced = 93,				// the time presented is out of range or tolerance
	k_EResultSmsCodeFailed = 94,				// SMS code failure (no match, none pending, etc.)
	k_EResultAccountLimitExceeded = 95,			// Too many accounts access this resource
	k_EResultAccountActivityLimitExceeded = 96,	// Too many changes to this account
	k_EResultPhoneActivityLimitExceeded = 97,	// Too many changes to this phone
	k_EResultRefundToWallet = 98,				// Cannot refund to payment method, must use wallet
	k_EResultEmailSendFailure = 99,				// Cannot send an email
	k_EResultNotSettled = 100,					// Can't perform operation till payment has settled
	k_EResultNeedCaptcha = 101,					// Needs to provide a valid captcha
	k_EResultGSLTDenied = 102,					// a game server login token owned by this token's owner has been banned
	k_EResultGSOwnerDenied = 103,				// game server owner is denied for other reason (account lock, community ban, vac ban, missing phone)
	k_EResultInvalidItemType = 104,				// the type of thing we were requested to act on is invalid
	k_EResultIPBanned = 105,					// the ip address has been banned from taking this action
	k_EResultGSLTExpired = 106,					// this token has expired from disuse; can be reset for use
	k_EResultInsufficientFunds = 107,			// user doesn't have enough wallet funds to complete the action
	k_EResultTooManyPending = 108,				// There are too many of this thing pending already
	k_EResultNoSiteLicensesFound = 109,			// No site licenses found
	k_EResultWGNetworkSendExceeded = 110,		// the WG couldn't send a response because we exceeded max network send size
	k_EResultAccountNotFriends = 111,			// the user is not mutually friends
	k_EResultLimitedUserAccount = 112,			// the user is limited
	k_EResultCantRemoveItem = 113,				// item can't be removed
	k_EResultAccountDeleted = 114,				// account has been deleted
	k_EResultExistingUserCancelledLicense = 115,	// A license for this already exists, but cancelled
	k_EResultCommunityCooldown = 116,			// access is denied because of a community cooldown (probably from support profile data resets)
	k_EResultNoLauncherSpecified = 117,			// No launcher was specified, but a launcher was needed to choose correct realm for operation.
	k_EResultMustAgreeToSSA = 118,				// User must agree to china SSA or global SSA before login
	k_EResultLauncherMigrated = 119,			// The specified launcher type is no longer supported; the user should be directed elsewhere
	k_EResultSteamRealmMismatch = 120,			// The user's realm does not match the realm of the requested resource
	k_EResultInvalidSignature = 121,			// signature check did not match
	k_EResultParseFailure = 122,				// Failed to parse input
	k_EResultNoVerifiedPhone = 123,				// account does not have a verified phone number
	k_EResultInsufficientBattery = 124,			// user device doesn't have enough battery charge currently to complete the action
	k_EResultChargerRequired = 125,				// The operation requires a charger to be plugged in, which wasn't present
	k_EResultCachedCredentialInvalid = 126,		// Cached credential was invalid - user must reauthenticate
};

IPAddr :: struct {
    using _ : struct #raw_union {
        m_ipv6: [16]u8,
        // Skipping the IPv4 field
    }, 
    m_port: u16,
}

ESteamNetworkingConfigValue :: enum libc.int
{
	k_ESteamNetworkingConfig_Invalid = 0,
	k_ESteamNetworkingConfig_TimeoutInitial = 24,
	k_ESteamNetworkingConfig_TimeoutConnected = 25,
	k_ESteamNetworkingConfig_SendBufferSize = 9,
	k_ESteamNetworkingConfig_ConnectionUserData = 40,
	k_ESteamNetworkingConfig_SendRateMin = 10,
	k_ESteamNetworkingConfig_SendRateMax = 11,
	k_ESteamNetworkingConfig_NagleTime = 12,
	k_ESteamNetworkingConfig_IP_AllowWithoutAuth = 23,
	k_ESteamNetworkingConfig_MTU_PacketSize = 32,
	k_ESteamNetworkingConfig_MTU_DataSize = 33,
	k_ESteamNetworkingConfig_Unencrypted = 34,
	k_ESteamNetworkingConfig_SymmetricConnect = 37,
	k_ESteamNetworkingConfig_LocalVirtualPort = 38,
	k_ESteamNetworkingConfig_EnableDiagnosticsUI = 46,
	k_ESteamNetworkingConfig_FakePacketLoss_Send = 2,
	k_ESteamNetworkingConfig_FakePacketLoss_Recv = 3,
	k_ESteamNetworkingConfig_FakePacketLag_Send = 4,
	k_ESteamNetworkingConfig_FakePacketLag_Recv = 5,
	k_ESteamNetworkingConfig_FakePacketReorder_Send = 6,
	k_ESteamNetworkingConfig_FakePacketReorder_Recv = 7,
	k_ESteamNetworkingConfig_FakePacketReorder_Time = 8,
	k_ESteamNetworkingConfig_FakePacketDup_Send = 26,
	k_ESteamNetworkingConfig_FakePacketDup_Recv = 27,
	k_ESteamNetworkingConfig_FakePacketDup_TimeMax = 28,
	k_ESteamNetworkingConfig_PacketTraceMaxBytes = 41,
	k_ESteamNetworkingConfig_FakeRateLimit_Send_Rate = 42,
	k_ESteamNetworkingConfig_FakeRateLimit_Send_Burst = 43,
	k_ESteamNetworkingConfig_FakeRateLimit_Recv_Rate = 44,
	k_ESteamNetworkingConfig_FakeRateLimit_Recv_Burst = 45,

	k_ESteamNetworkingConfig_Callback_ConnectionStatusChanged = 201,
	k_ESteamNetworkingConfig_Callback_AuthStatusChanged = 202,
	k_ESteamNetworkingConfig_Callback_RelayNetworkStatusChanged = 203,
	k_ESteamNetworkingConfig_Callback_MessagesSessionRequest = 204,
	k_ESteamNetworkingConfig_Callback_MessagesSessionFailed = 205,
	k_ESteamNetworkingConfig_Callback_CreateConnectionSignaling = 206,
	k_ESteamNetworkingConfig_Callback_FakeIPResult = 207,

	k_ESteamNetworkingConfig_P2P_STUN_ServerList = 103,
	k_ESteamNetworkingConfig_P2P_Transport_ICE_Enable = 104,
	k_ESteamNetworkingConfig_P2P_Transport_ICE_Penalty = 105,
	k_ESteamNetworkingConfig_P2P_Transport_SDR_Penalty = 106,
	k_ESteamNetworkingConfig_P2P_TURN_ServerList = 107,
	k_ESteamNetworkingConfig_P2P_TURN_UserList = 108,
	k_ESteamNetworkingConfig_P2P_TURN_PassList = 109,
	//k_ESteamNetworkingConfig_P2P_Transport_LANBeacon_Penalty = 107,
	k_ESteamNetworkingConfig_P2P_Transport_ICE_Implementation = 110,

	k_ESteamNetworkingConfig_SDRClient_ConsecutitivePingTimeoutsFailInitial = 19,
	k_ESteamNetworkingConfig_SDRClient_ConsecutitivePingTimeoutsFail = 20,
	k_ESteamNetworkingConfig_SDRClient_MinPingsBeforePingAccurate = 21,
	k_ESteamNetworkingConfig_SDRClient_SingleSocket = 22,
	k_ESteamNetworkingConfig_SDRClient_ForceRelayCluster = 29,
	k_ESteamNetworkingConfig_SDRClient_DebugTicketAddress = 30,
	k_ESteamNetworkingConfig_SDRClient_ForceProxyAddr = 31,
	k_ESteamNetworkingConfig_SDRClient_FakeClusterPing = 36,

	k_ESteamNetworkingConfig_LogLevel_AckRTT = 13, // [connection int32] RTT calculations for inline pings and replies
	k_ESteamNetworkingConfig_LogLevel_PacketDecode = 14, // [connection int32] log SNP packets send/recv
	k_ESteamNetworkingConfig_LogLevel_Message = 15, // [connection int32] log each message send/recv
	k_ESteamNetworkingConfig_LogLevel_PacketGaps = 16, // [connection int32] dropped packets
	k_ESteamNetworkingConfig_LogLevel_P2PRendezvous = 17, // [connection int32] P2P rendezvous messages
	k_ESteamNetworkingConfig_LogLevel_SDRRelayPings = 18, // [global int32] Ping relays


	// Deleted, do not use
	k_ESteamNetworkingConfig_DELETED_EnumerateDevVars = 35,

	k_ESteamNetworkingConfigValue__Force32Bit = 0x7fffffff
}

/// Configuration options
EConfigValue :: enum libc.int
{
	k_ESteamNetworkingConfig_Invalid = 0,
	k_ESteamNetworkingConfig_TimeoutInitial = 24,
	k_ESteamNetworkingConfig_TimeoutConnected = 25,
	k_ESteamNetworkingConfig_SendBufferSize = 9,
	k_ESteamNetworkingConfig_RecvBufferSize = 47,
	k_ESteamNetworkingConfig_RecvBufferMessages = 48,
	k_ESteamNetworkingConfig_RecvMaxMessageSize = 49,
	k_ESteamNetworkingConfig_RecvMaxSegmentsPerPacket = 50,
	k_ESteamNetworkingConfig_ConnectionUserData = 40,
	k_ESteamNetworkingConfig_SendRateMin = 10,
	k_ESteamNetworkingConfig_SendRateMax = 11,
	k_ESteamNetworkingConfig_NagleTime = 12,
	k_ESteamNetworkingConfig_IP_AllowWithoutAuth = 23,
	k_ESteamNetworkingConfig_MTU_PacketSize = 32,
	k_ESteamNetworkingConfig_MTU_DataSize = 33,
	k_ESteamNetworkingConfig_Unencrypted = 34,
	k_ESteamNetworkingConfig_SymmetricConnect = 37,
	k_ESteamNetworkingConfig_LocalVirtualPort = 38,
	k_ESteamNetworkingConfig_EnableDiagnosticsUI = 46,
	k_ESteamNetworkingConfig_FakePacketLoss_Send = 2,
	k_ESteamNetworkingConfig_FakePacketLoss_Recv = 3,
	k_ESteamNetworkingConfig_FakePacketLag_Send = 4,
	k_ESteamNetworkingConfig_FakePacketLag_Recv = 5,
	k_ESteamNetworkingConfig_FakePacketReorder_Send = 6,
	k_ESteamNetworkingConfig_FakePacketReorder_Recv = 7,
	k_ESteamNetworkingConfig_FakePacketReorder_Time = 8,
	k_ESteamNetworkingConfig_FakePacketDup_Send = 26,
	k_ESteamNetworkingConfig_FakePacketDup_Recv = 27,
	k_ESteamNetworkingConfig_FakePacketDup_TimeMax = 28,
	k_ESteamNetworkingConfig_PacketTraceMaxBytes = 41,
	k_ESteamNetworkingConfig_FakeRateLimit_Send_Rate = 42,
	k_ESteamNetworkingConfig_FakeRateLimit_Send_Burst = 43,
	k_ESteamNetworkingConfig_FakeRateLimit_Recv_Rate = 44,
	k_ESteamNetworkingConfig_FakeRateLimit_Recv_Burst = 45,

	k_ESteamNetworkingConfig_Callback_ConnectionStatusChanged = 201,
	k_ESteamNetworkingConfig_Callback_AuthStatusChanged = 202,
	k_ESteamNetworkingConfig_Callback_RelayNetworkStatusChanged = 203,
	k_ESteamNetworkingConfig_Callback_MessagesSessionRequest = 204,
	k_ESteamNetworkingConfig_Callback_MessagesSessionFailed = 205,
	k_ESteamNetworkingConfig_Callback_CreateConnectionSignaling = 206,
	k_ESteamNetworkingConfig_Callback_FakeIPResult = 207,

	k_ESteamNetworkingConfig_P2P_STUN_ServerList = 103,
	k_ESteamNetworkingConfig_P2P_Transport_ICE_Enable = 104,
	k_ESteamNetworkingConfig_P2P_Transport_ICE_Penalty = 105,
	k_ESteamNetworkingConfig_P2P_Transport_SDR_Penalty = 106,
	k_ESteamNetworkingConfig_P2P_TURN_ServerList = 107,
	k_ESteamNetworkingConfig_P2P_TURN_UserList = 108,
	k_ESteamNetworkingConfig_P2P_TURN_PassList = 109,
	//k_ESteamNetworkingConfig_P2P_Transport_LANBeacon_Penalty = 107,
	k_ESteamNetworkingConfig_P2P_Transport_ICE_Implementation = 110,

	k_ESteamNetworkingConfig_SDRClient_ConsecutitivePingTimeoutsFailInitial = 19,
	k_ESteamNetworkingConfig_SDRClient_ConsecutitivePingTimeoutsFail = 20,
	k_ESteamNetworkingConfig_SDRClient_MinPingsBeforePingAccurate = 21,
	k_ESteamNetworkingConfig_SDRClient_SingleSocket = 22,
	k_ESteamNetworkingConfig_SDRClient_ForceRelayCluster = 29,
	k_ESteamNetworkingConfig_SDRClient_DebugTicketAddress = 30,
	k_ESteamNetworkingConfig_SDRClient_ForceProxyAddr = 31,
	k_ESteamNetworkingConfig_SDRClient_FakeClusterPing = 36,

	k_ESteamNetworkingConfig_LogLevel_AckRTT = 13, // [connection int32] RTT calculations for inline pings and replies
	k_ESteamNetworkingConfig_LogLevel_PacketDecode = 14, // [connection int32] log SNP packets send/recv
	k_ESteamNetworkingConfig_LogLevel_Message = 15, // [connection int32] log each message send/recv
	k_ESteamNetworkingConfig_LogLevel_PacketGaps = 16, // [connection int32] dropped packets
	k_ESteamNetworkingConfig_LogLevel_P2PRendezvous = 17, // [connection int32] P2P rendezvous messages
	k_ESteamNetworkingConfig_LogLevel_SDRRelayPings = 18, // [global int32] Ping relays

	k_ESteamNetworkingConfig_ECN = 999,

	// Deleted, do not use
	k_ESteamNetworkingConfig_DELETED_EnumerateDevVars = 35,

	k_ESteamNetworkingConfigValue__Force32Bit = 0x7fffffff
};

// Different configuration values have different data types
EConfigDataType :: enum libc.int
{
	k_ESteamNetworkingConfig_Int32 = 1,
	k_ESteamNetworkingConfig_Int64 = 2,
	k_ESteamNetworkingConfig_Float = 3,
	k_ESteamNetworkingConfig_String = 4,
	k_ESteamNetworkingConfig_Ptr = 5,

	k_ESteamNetworkingConfigDataType__Force32Bit = 0x7fffffff
};

ConfigValue :: struct {
    m_eValue: EConfigValue,
    m_eDataType: EConfigDataType,
    m_val: struct #raw_union {
        m_int32: i32,
        m_int64: i64,
        m_float: f32,
        m_string: cstring,
        m_ptr: rawptr
    }
}

ESocketsDebugOutputType :: enum libc.int
{
	k_ESteamNetworkingSocketsDebugOutputType_None = 0,
	k_ESteamNetworkingSocketsDebugOutputType_Bug = 1, // You used the API incorrectly, or an internal error happened
	k_ESteamNetworkingSocketsDebugOutputType_Error = 2, // Run-time error condition that isn't the result of a bug.  (E.g. we are offline, cannot bind a port, etc)
	k_ESteamNetworkingSocketsDebugOutputType_Important = 3, // Nothing is wrong, but this is an important notification
	k_ESteamNetworkingSocketsDebugOutputType_Warning = 4,
	k_ESteamNetworkingSocketsDebugOutputType_Msg = 5, // Recommended amount
	k_ESteamNetworkingSocketsDebugOutputType_Verbose = 6, // Quite a bit
	k_ESteamNetworkingSocketsDebugOutputType_Debug = 7, // Practically everything
	k_ESteamNetworkingSocketsDebugOutputType_Everything = 8, // Wall of text, detailed packet contents breakdown, etc

	k_ESteamNetworkingSocketsDebugOutputType__Force32Bit = 0x7fffffff
}

/// Different methods of describing the identity of a network host
EIdentityType :: enum libc.int
{
	// Dummy/empty/invalid.
	// Please note that if we parse a string that we don't recognize
	// but that appears reasonable, we will NOT use this type.  Instead
	// we'll use k_ESteamNetworkingIdentityType_UnknownType.
	k_ESteamNetworkingIdentityType_Invalid = 0,

	//
	// Basic platform-specific identifiers.
	//
	k_ESteamNetworkingIdentityType_SteamID = 16, // 64-bit CSteamID

	//
	// Special identifiers.
	//

	// Use their IP address (and port) as their "identity".
	// These types of identities are always unauthenticated.
	// They are useful for porting plain sockets code, and other
	// situations where you don't care about authentication.  In this
	// case, the local identity will be "localhost",
	// and the remote address will be their network address.
	//
	// We use the same type for either IPv4 or IPv6, and
	// the address is always store as IPv6.  We use IPv4
	// mapped addresses to handle IPv4.
	k_ESteamNetworkingIdentityType_IPAddress = 1,

	// Generic string/binary blobs.  It's up to your app to interpret this.
	// This library can tell you if the remote host presented a certificate
	// signed by somebody you have chosen to trust, with this identity on it.
	// It's up to you to ultimately decide what this identity means.
	k_ESteamNetworkingIdentityType_GenericString = 2,
	k_ESteamNetworkingIdentityType_GenericBytes = 3,

	// This identity type is used when we parse a string that looks like is a
	// valid identity, just of a kind that we don't recognize.  In this case, we
	// can often still communicate with the peer!  Allowing such identities
	// for types we do not recognize useful is very useful for forward
	// compatibility.
	k_ESteamNetworkingIdentityType_UnknownType = 4,

	// Make sure this enum is stored in an int.
	k_ESteamNetworkingIdentityType__Force32bit = 0x7fffffff,
};

Identity :: struct #packed
{
	/// Type of identity.
	m_eType: EIdentityType,

    m_cbSize: libc.int,
	using _ : struct #raw_union {
        m_ip: IPAddr,
		m_reserved: [ 32 ]u32, // Pad structure to leave easy room for future expansion
	},
}

/// High level connection status
EConnectionState :: enum libc.int
{

	k_ESteamNetworkingConnectionState_None = 0,
	k_ESteamNetworkingConnectionState_Connecting = 1,
	k_ESteamNetworkingConnectionState_FindingRoute = 2,
	k_ESteamNetworkingConnectionState_Connected = 3,
	k_ESteamNetworkingConnectionState_ClosedByPeer = 4,
	k_ESteamNetworkingConnectionState_ProblemDetectedLocally = 5,
	k_ESteamNetworkingConnectionState_FinWait = -1,
	k_ESteamNetworkingConnectionState_Linger = -2, 
	k_ESteamNetworkingConnectionState_Dead = -3,

	k_ESteamNetworkingConnectionState__Force32Bit = 0x7fffffff
};

/// Describe the state of a connection.
ConnectionInfo :: struct
{

	m_identityRemote: Identity,
	m_nUserData: i64,
	m_hListenSocket: HSteamListenSocket,
	m_addrRemote: IPAddr,
	m__pad1: u16,
	m_idPOPRemote: POPID,
	m_idPOPRelay: POPID,
	m_eState: EConnectionState,
	m_eEndReason: libc.int,
	m_szEndDebug: [ k_cchSteamNetworkingMaxConnectionCloseReason ]libc.char,
	m_szConnectionDescription: [ k_cchSteamNetworkingMaxConnectionDescription ]libc.char,
	m_nFlags: libc.int,

	/// Internal stuff, room to change API easily
	reserved: [63]libc.uint,
}

SteamNetConnectionStatusChangedCallback_t :: struct
{ 
	m_hConn: HSteamNetConnection,
	m_info: ConnectionInfo,
	m_eOldState: EConnectionState
};

Message :: struct
{

	m_pData: rawptr,

	m_cbSize: libc.int,

	m_conn: HSteamNetConnection,

	m_identityPeer: Identity,

	m_nConnUserData: i64,

	m_usecTimeReceived: Microseconds,

	m_nMessageNumber: i64,

    m_pfnFreeData: proc(pMsg: ^Message),
    m_pfnRelease: proc(pMsg: ^Message),

	m_nChannel: libc.int,

	m_nFlags: libc.int,

	m_nUserData: i64,

	m_idxLane: u16,
	 _pad1__: u16,
}

FSocketsDebugOutput :: proc(nType: ESocketsDebugOutputType, pszMsg: cstring)
FnSteamNetConnectionStatusChanged :: proc(callback: SteamNetConnectionStatusChangedCallback_t)
FSteamNetworkingSocketsCustomSignaling_SendSignal :: proc(ctx: rawptr, hConn: HSteamNetConnection, info: ^ConnectionInfo, pMsg: rawptr, cbMsg: libc.int) -> bool
FSteamNetworkingSocketsCustomSignaling_Release :: proc(ctx: rawptr)
FSteamNetworkingCustomSignalingRecvContext_OnConnectRequest :: proc(ctx: rawptr, hConn: HSteamNetConnection, identityPeer: ^Identity, nLocalVirtualPort: libc.int) -> ConnectionSignalingPtr
FSteamNetworkingCustomSignalingRecvContext_SendRejectionSignal :: proc(ctx: rawptr, identityPeer: ^Identity, pMsg: rawptr, cbMsg: libc.int)


foreign import gamenetworkingsockets "GameNetworkingSockets.lib"

@(link_prefix="GameNetworkingSockets_")
foreign gamenetworkingsockets {
    Init :: proc(pIdentity: ^Identity, errMsg: DatagramErrMsg) -> bool ---
}

@(link_prefix="SteamAPI_SteamNetworkingSockets_")
foreign gamenetworkingsockets {
    v009 :: proc() -> SocketsPtr ---
}

@(link_prefix="SteamAPI_ISteamNetworkingSockets_")
foreign gamenetworkingsockets {
    CreateListenSocketP2P :: proc(self: SocketsPtr, nLocalVirtualPort: libc.int, nOptions: libc.int, pOptions: [^]ConfigValue) -> HSteamListenSocket ---
    CreateListenSocketIP :: proc(self: SocketsPtr, localAddress: ^IPAddr, nOptions: libc.int, pOptions: [^]ConfigValue) -> HSteamListenSocket ---
    ConnectByIPAddress :: proc(self: SocketsPtr, address: ^IPAddr, nOptions: libc.int, pOptions: [^]ConfigValue) -> HSteamNetConnection ---
    ConnectP2P :: proc(self: SocketsPtr, identityRemote: ^Identity, nRemoteVirtualPort: libc.int, nOptions: libc.int, pOptions: [^]ConfigValue) -> HSteamNetConnection ---

    RunCallbacks :: proc(self: SocketsPtr) ---
    CreatePollGroup :: proc(self: SocketsPtr) -> HSteamNetPollGroup ---
    SetConnectionPollGroup :: proc(self: SocketsPtr, hConn: HSteamNetConnection, hPollGroup: HSteamNetPollGroup) -> bool ---
    AcceptConnection :: proc(self: SocketsPtr, hConn: HSteamNetConnection) -> EResult ---
    CloseConnection :: proc(self: SocketsPtr, hPeer: HSteamNetConnection, nReason: libc.int, pszDebug: cstring, bEnableLinger: bool) -> bool ---
    SendMessageToConnection :: proc(self: SocketsPtr, hConn: HSteamNetConnection, pData: rawptr, cbData: u32, nSendFlags: libc.int, pOutMessageNumber: ^i64) -> EResult ---
    CloseListenSocket :: proc(self: SocketsPtr, hSocket: HSteamListenSocket) -> bool ---
    ReceiveMessagesOnConnection :: proc(self: SocketsPtr, hConn: HSteamNetConnection, ppOutMessages: [^]^Message, nMaxMessages: libc.int) -> libc.int ---
    ReceiveMessagesOnPollGroup :: proc(self: SocketsPtr, hPollGroup: HSteamNetPollGroup, ppOutMessages: [^]^Message, nMaxMessages: libc.int) -> libc.int ---
    GetIdentity :: proc(self: SocketsPtr, pIdentity: ^Identity) -> bool ---
    CreateCustomSignaling :: proc(ctx: rawptr, fnSendSignal: FSteamNetworkingSocketsCustomSignaling_SendSignal, fnRelease: FSteamNetworkingSocketsCustomSignaling_Release) -> ConnectionSignalingPtr ---
    ReceivedP2PCustomSignal2 :: proc(self: SocketsPtr, pMsg: rawptr, cbMsg: libc.int, ctx: rawptr, fnOnConnectRequest: FSteamNetworkingCustomSignalingRecvContext_OnConnectRequest, fnSendRejectionSignal: FSteamNetworkingCustomSignalingRecvContext_SendRejectionSignal) -> bool ---
    ConnectP2PCustomSignaling :: proc(self: SocketsPtr, pSignaling: ConnectionSignalingPtr, pPeerIdentity: ^Identity, nRemoteVirtualPort: libc.int, nOptions: libc.int, pOptions: [^]ConfigValue) -> HSteamNetConnection ---
}

@(link_prefix="SteamAPI_SteamNetworking")
foreign gamenetworkingsockets {
    Utils_v003 :: proc() -> UtilsPtr ---
}


@(link_prefix="SteamAPI_ISteamNetworking")
foreign gamenetworkingsockets {
    Utils_SetDebugOutputFunction :: proc(self: UtilsPtr, eDetailLevel: ESocketsDebugOutputType, pfnFunc: FSocketsDebugOutput) ---
    Utils_SetGlobalConfigValueInt32 :: proc(self: UtilsPtr, eValue: ESteamNetworkingConfigValue, val: i32) -> bool ---
    Utils_SetGlobalConfigValueFloat :: proc(self: UtilsPtr, eValue: ESteamNetworkingConfigValue, val: f32) -> bool ---
    Utils_SetGlobalConfigValueString :: proc(self: UtilsPtr, eValue: ESteamNetworkingConfigValue, val: cstring) -> bool ---
    Utils_SetGlobalConfigValuePtr :: proc(self: UtilsPtr, eValue: ESteamNetworkingConfigValue, val: rawptr) -> bool ---
    Utils_SetGlobalCallback_SteamNetConnectionStatusChanged :: proc(self: UtilsPtr, callback: FnSteamNetConnectionStatusChanged) -> bool ---
}

@(link_prefix="SteamAPI_SteamNetworking")
foreign gamenetworkingsockets {
    IPAddr_Clear :: proc(self: ^IPAddr) ---
    IPAddr_ParseString :: proc(self: ^IPAddr, pszStr: cstring ) -> bool ---
}

@(link_prefix="SteamAPI_SteamNetworkingMessage_t_")
foreign gamenetworkingsockets {
    Release :: proc(self: ^Message) ---
}

@(link_prefix="SteamAPI_SteamNetworking")
foreign gamenetworkingsockets {
    Identity_Clear :: proc(self: ^Identity) ---
    Identity_SetIPAddr :: proc(self: ^Identity, addr: ^IPAddr) ---
    Identity_ParseString :: proc(self: ^Identity, sizeofIdentity: libc.size_t, pszStr: cstring) -> bool ---
    Identity_ToString :: proc(self: ^Identity, buf: [^]libc.char, cbBuf: libc.size_t) ---
    Identity_SetLocalHost :: proc(self: ^Identity) ---
}


