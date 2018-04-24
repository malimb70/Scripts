vcl 4.0;

backend mpt_inp{
  .host = "10.133.104.33";
  .port = "80";
  .host_header = "inp.staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 3;
        }
}

backend mpt_homepage_01{
  .host = "172.31.68.92";
  .port = "80";
  .connect_timeout = 1.5s;
  .host_header = "staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 5;
        }
}

backend mpt_homepage_02{
  .host = "172.31.75.16";
  .port = "80";
  .connect_timeout = 1.5s;
  .host_header = "staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 5;
        }
}

backend mat_mpt_01{
  .host = "172.31.68.92";
  .port = "80";
  .connect_timeout = 1.5s;
  .host_header = "mat-staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 5;
        }
}

backend mat_mpt_02{
  .host = "172.31.75.16";
  .port = "80";
  .connect_timeout = 1.5s;
  .host_header = "mat-staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 5;
        }
}


backend mpt_test_homepage_01{
  .host = "172.31.68.92";
  .port = "80";
  .connect_timeout = 1.5s;
  .host_header = "test.staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 5;
        }
}


backend mpt_test_homepage_02{
  .host = "172.31.75.16";
  .port = "80";
  .connect_timeout = 1.5s;
  .host_header = "test.staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 5;
        }
}

backend mpt_test_01{
  .host = "172.31.68.92";
  .port = "80";
  .connect_timeout = 1.5s;
  .host_header = "test.staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 5;
        }
}

backend mpt_test_02{
  .host = "172.31.75.16";
  .port = "80";
  .connect_timeout = 1.5s;
  .host_header = "test.staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 5;
        }
}

backend mpt_api_01{
  .host = "10.133.103.173";
  .port = "80";
  .host_header = "api-staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 3;
        }
}

backend mpt_medforum_01{
  .host = "10.133.103.173";
  .port = "80";
  .connect_timeout = 1.5s;
  .host_header = "medforum.staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 3;
        }
}

backend mpt{
  .host = "10.133.103.100";
  .port = "80";
  .connect_timeout = 1.5s;
  .host_header = "staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 3;
        }
}

backend mpt_devwerp{
  .host = "10.133.103.100";
  .port = "80";
  .connect_timeout = 1.5s;
  .host_header = "staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
                .window = 5;
                .threshold = 3;
        }
}


backend mpt_apibe_01{
  .host = "10.133.103.173";
  .port = "80";
  .host_header = "apibe.staging.medpagetoday.com";
  .probe = {
                .url = "/status.html";
                .interval = 15s;
                .timeout = 180 s;
		.window = 5;
                .threshold = 3;
        }
}

backend mpt_homepage_03{
     .host = "10.133.104.22";
     .port = "80"; 
     .connect_timeout = 1.5s;
     .host_header = "staging.medpagetoday.com";
     .probe = {
         .url = "/status.html";
         .interval = 15s;
         .timeout = 180 s;
         .window = 5;
         .threshold = 5;
    }
}


backend mpt_homepage_03{
     .host = "10.133.104.22";
     .port = "80"; 
     .connect_timeout = 1.5s;
     .host_header = "staging.medpagetoday.com";
     .probe = {
         .url = "/status.html";
         .interval = 15s;
         .timeout = 180 s;
         .window = 5;
         .threshold = 5;
    }
}


backend mpt_homepage_03{
     .host = "10.133.104.22";
     .port = "80"; 
     .connect_timeout = 1.5s;
     .host_header = "staging.medpagetoday.com";
     .probe = {
         .url = "/status.html";
         .interval = 15s;
         .timeout = 180 s;
         .window = 5;
         .threshold = 5;
    }
}


sub vcl_init    {
        new mpt_medforum_dir = directors.hash();
        mpt_medforum_dir.add_backend(mpt_medforum_01, 1);

        new mpt_api_dir = directors.hash();
        mpt_api_dir.add_backend(mpt_api_01, 1);

        new mpt_dir = directors.hash();
        mpt_dir.add_backend(mpt, 1);

        new mpt_devwerp_dir = directors.hash();
        mpt_devwerp_dir.add_backend(mpt_devwerp, 1);

        new mpt_homepage_dir = directors.hash();
        mpt_homepage_dir.add_backend(mpt_homepage_01, 1);
	mpt_homepage_dir.add_backend(mpt_homepage_02, 1);

        new mpt_mat_dir = directors.hash();
        mpt_mat_dir.add_backend(mat_mpt_01, 1);
        mpt_mat_dir.add_backend(mat_mpt_02, 1);

   	new mpt_test_homepage_dir = directors.hash();
    	mpt_test_homepage_dir.add_backend(mpt_test_homepage_01, 1);
	mpt_test_homepage_dir.add_backend(mpt_test_homepage_02, 1);

    	new mpt_test_dir = directors.hash();
    	mpt_test_dir.add_backend(mpt_test_01, 1);
	mpt_test_dir.add_backend(mpt_test_02, 1);

        new mpt_inp_dir = directors.hash();
        mpt_inp_dir.add_backend(mpt_inp, 1);

  	new mpt_apibe_dir = directors.hash();
  	mpt_apibe_dir.add_backend(mpt_apibe_01, 1);
}

sub vcl_recv {
set req.http.mpt_main = "staging.medpagetoday.com";
set req.http.mpt_inp = "inp.staging.medpagetoday.com";
set req.http.mpt_medforum = "medforum.staging.medpagetoday.com";
set req.http.mpt_api = "api-staging.medpagetoday.com";
set req.http.mpt_test = "test.staging.medpagetoday.com";
set req.http.mpt_apibe = "apibe.staging.medpagetoday.com";
set req.http.mpt_mat = "mat-staging.medpagetoday.com";
}

sub vcl_backend_fetch {
set bereq.http.mpt_main = "staging.medpagetoday.com";
set bereq.http.mpt_inp = "inp.staging.medpagetoday.com";
set bereq.http.mpt_medforum = "medforum.staging.medpagetoday.com";
set bereq.http.mpt_api = "api-staging.medpagetoday.com";
set bereq.http.mpt_test = "test.staging.medpagetoday.com";
set bereq.http.mpt_apibe = "apibe.staging.medpagetoday.com";
set bereq.http.mpt_mat = "mat-staging.medpagetoday.com";
}

