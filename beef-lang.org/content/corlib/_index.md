+++
title = "Core Libraries"
weight = 40
+++

## Beef core libraries overview

The basic standard Beef is called "corlib", and provides access to basic utility types and access to general system functionality.

The following is a partial list of collection types provided by corlib.

|Category|Types|
|-----|------|
|List|[System.Collections.List<T>](../doxygen/corlib/html/class_system_1_1_collections_1_1_list.html)|
|Dictionary|[System.Collections.Dictionary<T>](https://github.com/beefytech/Beef/blob/master/BeefLibs/corlib/src/Collections/Dictionary.bf)|
|Hash set|[System.Collections.HashSet<T>](../doxygen/corlib/html/class_system_1_1_collections_1_1_hash_set.html)|
|Queue|[System.Collections.Queue<T>](../doxygen/corlib/html/class_system_1_1_collections_1_1_queue.html)|

The following is a parial list of the funtionality provided by corlib. See the complete API documentation for the full list.

|Category|Types|
|-----|------|
|Strings|[System.String](../doxygen/corlib/html/class_system_1_1_string.html)<br/>[System.StringView](../doxygen/corlib/html/struct_system_1_1_string_view.html)|
|Math|[System.Math](../doxygen/corlib/html/class_system_1_1_math.html)|
|Random|[System.Random](../doxygen/corlib/html/class_system_1_1_random.html)|
|Error handling|[System.Result<T>](../doxygen/corlib/html/struct_system_1_1_result.html)|
|Files and Directories|[System.IO.File](../doxygen/corlib/html/class_system_1_1_i_o_1_1_file.html)<br/>[System.IO.FileStream](../doxygen/corlib/html/class_system_1_1_i_o_1_1_file_stream.html)<br/>[System.IO.Directory](../doxygen/corlib/html/class_system_1_1_i_o_1_1_directory.html)<br/>[System.IO.Path](../doxygen/corlib/html/class_system_1_1_i_o_1_1_path.html)|
|Date and Time|[System.DateTime](../doxygen/corlib/html/struct_system_1_1_date_time.html)|
|Timing|[System.Diagnostics.Stopwatch](../doxygen/corlib/html/class_system_1_1_diagnostics_1_1_stopwatch.html)|
|Sockets|[System.Net.Socket](../doxygen/corlib/html/class_system_1_1_net_1_1_socket.html)|
|Threading|[System.Threading.Thread](../doxygen/corlib/html/class_system_1_1_threading_1_1_thread.html)<br/>[System.Threading.ThreadPool](../doxygen/corlib/html/class_system_1_1_threading_1_1_thread_pool.html)<br/>[System.Threading.Monitor](../doxygen/corlib/html/class_system_1_1_threading_1_1_monitor.html)<br/>[System.Threading.WaitEvent](../doxygen/corlib/html/class_system_1_1_threading_1_1_wait_event.html)|
|Atomic Operations|[System.Threading.Interlocked](../doxygen/corlib/html/class_system_1_1_threading_1_1_interlocked.html)|
|Console|[System.Console](../doxygen/corlib/html/class_system_1_1_console.html)|
|Debug helpers|[System.Diagnostics.Debug](../doxygen/corlib/html/class_system_1_1_diagnostics_1_1_debug.html)|
|Hashing|[System.Cryptography.MD5Hash](../doxygen/corlib/html/class_system_1_1_security_1_1_cryptography_1_1_m_d5.html)<br/>[System.Cryptography.SHA256](../doxygen/corlib/html/struct_system_1_1_security_1_1_cryptography_1_1_s_h_a256.html)|
|Text Encoding|[System.Text.Encoding](../doxygen/corlib/html/class_system_1_1_text_1_1_encoding.html)|
|Multi-cast delegates|[System.Event<T>](../doxygen/corlib/html/struct_system_1_1_event.html)|
|FFI|[System.FFI.FFILIB](../doxygen/corlib/html/struct_system_1_1_f_f_i_1_1_f_f_i_l_i_b.html)<br/>[System.FFI.FFIType](../doxygen/corlib/html/struct_system_1_1_f_f_i_1_1_f_f_i_type.html)<br/>[System.FFI.FFICaller](../doxygen/corlib/html/struct_system_1_1_f_f_i_1_1_f_f_i_caller.html)|
|Windows API|[System.Windows](../doxygen/corlib/html/class_system_1_1_windows.html)|

## Multimedia libraries

The Beef IDE utilizes a windowing and multimedia library named Beefy2D. This library is only intended for use by the IDE and other internal Beef tools. This library is not documented or supported for this-party applications, and the API will change without regard for backwards compatibility. As such, other third-party libraries should be used by third-party applications.

One example of a third-party multimedia library is SDL2, whose use is illustrated in the included Beef samples.
