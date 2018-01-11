{
    "targets": [
        {
          'target_name': '{{ module_name }}',
          'sources': [ {{ sources }} ],
          'include_dirs': [ {{ includes }} ],
          'cflags': [ {{ flags }} ],
          'libraries': [ {{ libs }} ],
        }
    ]
}
