{
	/**
	 * Required!
	 * Path to header file with metadata (for Makefile)
	 * Example: tests/EAPI/EApi.h
	 */
	"header": "tests/c_project/my_program.h", 

	/**
	 * Full path to header file in target device (for Makefile)
	 * Default: Copy "header" file to build folder
	 * Example: /home/user/my_lib/my_header.h
	 */
	"header_path": 

	/**
	 * Build folder (for Makefile)
	 * Default: "build"
	 */
	"build_path": "",

	/**
	 * Name that will be used as application name or module name
	 * Default: header name
	 */
	"program_name": "",

	/**
	 * Save as archive
	 * Default: false
	 */
	"archive": false,

	/**
	 * Required!
	 * Target of building
	 */
	"out": {
		"duktape": {},
		
		"jerryscript": {},
		
		"shell": {			
			/**
			 * Default: "targets/linux"
			 */
			"target": "targets/tirtos_msp430",

			/**
			 * Creating Makefile and main.c
			 */
			"with_app": false, 

			/**
			 * Full path to include folders (for Makefile)
			 * Default: None
			 * Example: ["-I/home/user/include"]
			 */
			"include": [],
			
			/**
			 * Full path to binary objects (for Makefile)
			 * Default: None
			 * Example: ["tests/c_project/my_program.o"]
			 */
			"source": [],
			
			/**
			 * libraries (for Makefile)
			 * Default: None
			 * Example: ["-L/home/user/lib -lmylib"]
			 */
			"libs": [],

			/**
			 * libraries (for Makefile)
			 * Default: None
			 * Example: ["-Wall"]
			 */
			"flags": []
		},

		"nodered": {},
		
		"nodejs": {
			"include": [],
			"source": [],
			"libs": [],
			"flags": []
		},

		"express": {}, 

		"civetweb": {}, 

		"nodejs_uart_client": {}
	}
}