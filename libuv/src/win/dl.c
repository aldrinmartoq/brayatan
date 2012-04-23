/* Copyright Joyent, Inc. and other Node contributors. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

#include "uv.h"
#include "internal.h"


uv_err_t uv_dlopen(const char* filename, uv_lib_t* library) {
  wchar_t filename_w[32768];
  HMODULE handle;

  if (!uv_utf8_to_utf16(filename,
                        filename_w,
                        sizeof(filename_w) / sizeof(wchar_t))) {
    return uv__new_sys_error(GetLastError());
  }

  handle = LoadLibraryW(filename_w);
  if (handle == NULL) {
    return uv__new_sys_error(GetLastError());
  }

  *library = handle;
  return uv_ok_;
}


uv_err_t uv_dlclose(uv_lib_t library) {
  if (!FreeLibrary(library)) {
    return uv__new_sys_error(GetLastError());
  }

  return uv_ok_;
}


uv_err_t uv_dlsym(uv_lib_t library, const char* name, void** ptr) {
  FARPROC proc = GetProcAddress(library, name);
  if (proc == NULL) {
    return uv__new_sys_error(GetLastError());
  }

  *ptr = (void*) proc;
  return uv_ok_;
}
