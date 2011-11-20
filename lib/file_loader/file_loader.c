#include <stdio.h>
#include <string.h>
#include <dirent.h>
#include <regex.h>
#include <stdlib.h>
#include <regex.h>
#include "ruby.h"

void getdir(const char*, VALUE);
VALUE wrap_getdir(VALUE, VALUE);
void Init_test();
static size_t getfilesize(FILE*);

/*
int main (int argc, char* argv[]) {
  char path[512];

  ruby_init();
  ruby_init_loadpath();
  ruby_script("test");
  rb_require("digest/md5");

  if (argc <= 1) {
    strcpy(path, ".");
  } else {
    int i = strlen(argv[1]);
    if (argv[1][i-1] == '/') {
      argv[1][i-1] = '\0';
    }
    printf("%s\n", argv[1]);
    strcpy(path, argv[1]);
  }

  getdir(path);

  ruby_finalize();

  return 0;
}
*/


void getdir(const char *path, VALUE parent_dir) {
  DIR *dir;
  struct dirent *dp;
  char filepath[1024];
  char buf[300*1024];
  char cDigest[32];
  char evalBuf[2048];

  regex_t preg;
  size_t nmatch = 2;
  regmatch_t pmatch[nmatch];

  FILE *fp;

  VALUE directory;
  VALUE saved;

  VALUE mDigest = rb_path2class("Digest");
  VALUE cPasokaraFile = rb_path2class("PasokaraFile");
  VALUE cDirectory = rb_path2class("Directory");
  VALUE mMD5 = rb_path2class("Digest::MD5");

  if ((dir = opendir(path)) == NULL) {
    perror("opendir");
    exit(-1);
  }

  if (regcomp(&preg, "\\.(mpe?g|avi|flv|ogm|mkv|mp4|wmv|mov|rmvb|asf|webm|f4v|m4v)$", REG_EXTENDED|REG_ICASE) != 0) {
    printf("regex error\n");
    exit(-1);
  }

  for (dp = readdir(dir); dp != NULL; dp = readdir(dir)) {
    if (dp->d_name[0] == '.')
      continue;
    filepath[0] = '\0';

    strcat(filepath, path);
    strcat(filepath, "/");
    strcat(filepath, dp->d_name);

    DIR *next_dir;
    if ((next_dir = opendir(filepath)) != NULL) {
      printf("Loading Dir: %s\n", filepath);
      ID load_dir = rb_intern("load_dir");
      VALUE rPath = rb_external_str_new(filepath, strlen(filepath));
      directory = rb_funcall(cDirectory, load_dir, 2, rPath, parent_dir);
      closedir(next_dir);
      getdir(filepath, directory);
      continue;
    }

    if ((regexec(&preg, dp->d_name, nmatch, pmatch, 0)) != 0) {
      continue;
    }

    sprintf(evalBuf, "PasokaraFile.saved_file?(\"%s\")", filepath);
    VALUE saved = rb_eval_string(evalBuf);
    if (TYPE(saved) == T_TRUE) {
      continue;
    }

    if ((fp = fopen(filepath, "r")) == NULL) {
      printf("File open error: %s\n", filepath);
      continue;
    }

    printf("Loading: %s\n", filepath);
    size_t filesize = getfilesize(fp);
    int l = (filesize >= 300*1024) ? 300*1024 : (int)filesize;
    fread(buf, sizeof(char), l, fp);
    fclose(fp);

    ID mid;

    VALUE rString = rb_str_new(buf, l);
    mid = rb_intern("hexdigest");
    VALUE rDigest = rb_funcall(mMD5, mid, 1, rString);
    StringValue(rDigest);
    char *cDigest = RSTRING_PTR(rDigest);

    VALUE pasokara;
    sprintf(evalBuf, "PasokaraFile.find_or_initialize_by({:md5_hash => \"%s\"})", cDigest);
    pasokara = rb_eval_string(evalBuf);

    sprintf(evalBuf, "{:name => File.basename(\"%s\"), :fullpath => \"%s\", :md5_hash => \"%s\"}", filepath, filepath, cDigest);
    VALUE attr = rb_eval_string(evalBuf);
    mid = rb_intern("attributes=");
    rb_funcall(pasokara, mid, 1, attr);

    mid = rb_intern("directory=");
    rb_funcall(pasokara, mid, 1, parent_dir);

    mid = rb_intern("parse_info_file");
    rb_funcall(pasokara, mid, 0);

    mid = rb_intern("update_thumbnail");
    rb_funcall(pasokara, mid, 0);

    VALUE new_record;
    VALUE changed;
    mid = rb_intern("new_record?");
    new_record = rb_funcall(pasokara, mid, 0);
    mid = rb_intern("changed?");
    changed = rb_funcall(pasokara, mid, 0);

    if ((new_record == T_TRUE) || (changed == T_TRUE)) {
      mid = rb_intern("save");
      rb_funcall(pasokara, mid, 0);
    }

    printf("Done!\n");
  }
  closedir(dir);
}

VALUE wrap_getdir(VALUE self, VALUE path) {
  char *cPath = RSTRING_PTR(path);
  getdir(cPath, Qnil);
  return Qnil;
}

void Init_file_loader() {
  VALUE module;
  rb_require("digest/md5");
  rb_require("pasokara_file");
  rb_require("directory");
  rb_require("tag");

  module = rb_define_module("FileLoader");
  rb_define_module_function(module, "load_dir", wrap_getdir, 1);
}

static size_t getfilesize(FILE *fp) {
  size_t size;
  fseek(fp, 0, SEEK_END);
  size = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  return size;
}
