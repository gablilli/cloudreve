package constants

import "os"

// These values will be injected at build time, DO NOT EDIT.

// BackendVersion 当前后端版本号
var BackendVersion = "4.1.0 pro"

// IsPro 是否为Pro版本
// Default value may be overridden at build-time. For development convenience,
// if the environment variable `CR_DEV_LICENSE` is set (non-empty), we treat
// the build as Pro-enabled locally.
var IsPro = "false"

var IsProBool = IsPro == "true"

func init() {
	if v := os.Getenv("CR_DEV_LICENSE"); v != "" {
		IsPro = "true"
		IsProBool = true
	}
}

// LastCommit 最后commit id
var LastCommit = "000000"

const (
	APIPrefix      = "/api/v4"
	APIPrefixSlave = "/api/v4/slave"
	CrHeaderPrefix = "X-Cr-"
)

const CloudreveScheme = "cloudreve"

type (
	FileSystemType string
)

const (
	FileSystemMy           = FileSystemType("my")
	FileSystemShare        = FileSystemType("share")
	FileSystemTrash        = FileSystemType("trash")
	FileSystemSharedWithMe = FileSystemType("shared_with_me")
	FileSystemUnknown      = FileSystemType("unknown")
)
