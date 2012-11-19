/* This software is distributed under the GNU Lesser General Public License.
  *  See the root of this repository for details.
  *  Copyright 2011 Daniel Powell 
*/

#include <Python.h>

static PyObject *
audiopack_monopack(PyObject *self, PyObject *args)
// Package a Python object as a monaural audio frame.
{	
  union {
    short signal;
		char bytes[2];
  } u;
  char out[4];
  if (!PyArg_ParseTuple(args, "h", &u.signal))
    return NULL;
  out[0] = u.bytes[0];
  out[1] = u.bytes[1];
  out[2] = u.bytes[0];
  out[3] = u.bytes[1];	
  return Py_BuildValue("s#", out, 4);
}

static PyObject *
audiopack_stereopack(PyObject *self, PyObject *args)
// Package a Python object as a stereo audio frame.
{
  union {
    short signal;
    char bytes[2]; 
  } left;
  union {
    short signal;
    char bytes[2];
  } right;
  char out[4];
  
  if (!PyArg_ParseTuple(args, "hh", &left.signal, &right.signal))
    return NULL;
  out[0] = left.bytes[0];
  out[1] = left.bytes[1];
  out[2] = right.bytes[0];
  out[3] = right.bytes[1];
  return Py_BuildValue("s#", out, 4);
}

static PyMethodDef AudiopackMethods[] = {
  {"stereopack", audiopack_stereopack, METH_VARARGS,
   "Packs data into a stereo audio frame."},
  {"monopack", audiopack_monopack, METH_VARARGS,
   "Packs data into a monaural audio frame."},
  {NULL, NULL, 0, NULL}
};

PyMODINIT_FUNC
initaudiopack(void)
{
  (void) Py_InitModule("audiopack", AudiopackMethods);
}
