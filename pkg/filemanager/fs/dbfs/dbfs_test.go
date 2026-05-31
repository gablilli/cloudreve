package dbfs

import (
	"testing"

	"github.com/cloudreve/Cloudreve/v4/ent"
	"github.com/cloudreve/Cloudreve/v4/pkg/filemanager/fs"
)

func TestGenerateSavePathUsesUsernameAndOriginalPath(t *testing.T) {
	user := &ent.User{ID: 42, Nick: "pincopallino"}
	rootUpload, err := fs.NewUriFromString("cloudreve://my/ciao.mp4")
	if err != nil {
		t.Fatalf("failed to build uri: %v", err)
	}
	folderUpload, err := fs.NewUriFromString("cloudreve://my/quiquoqua/ciao.mp4")
	if err != nil {
		t.Fatalf("failed to build uri: %v", err)
	}

	if got := generateSavePath(nil, &fs.UploadRequest{Props: &fs.UploadProps{Uri: rootUpload}}, user); got != "pincopallino/ciao.mp4" {
		t.Fatalf("unexpected root save path: %q", got)
	}

	if got := generateSavePath(nil, &fs.UploadRequest{Props: &fs.UploadProps{Uri: folderUpload}}, user); got != "pincopallino/quiquoqua/ciao.mp4" {
		t.Fatalf("unexpected nested save path: %q", got)
	}
}
