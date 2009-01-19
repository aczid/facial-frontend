MERB_VERSION = '<= 1.0.8'
DM_VERSION = '<= 0.9.8'

dependency "merb-action-args", MERB_VERSION   # Provides support for querystring arguments to be passed in to controller actions
dependency "merb-assets", MERB_VERSION       # Provides link_to, asset_path, auto_link, image_tag methods (and lots more)
dependency "merb-cache", MERB_VERSION         # Provides your application with caching functions 
dependency "merb-helpers", MERB_VERSION       # Provides the form, date/time, and other helpers
#dependency "merb-mailer", MERB_VERSION        # Integrates mail support via Merb Mailer
dependency "merb-slices", MERB_VERSION        # Provides a mechanism for letting plugins provide controllers, views, etc. to your app
dependency "merb-auth", MERB_VERSION          # An authentication slice (Merb's equivalent to Rails' restful authentication)
dependency "merb-param-protection", MERB_VERSION
 
dependency "dm-core", DM_VERSION         # The datamapper ORM
#dependency "dm-aggregates", DM_VERSION   # Provides your DM models with count, sum, avg, min, max, etc.
dependency "dm-migrations", DM_VERSION   # Make incremental changes to your database.
dependency "dm-timestamps", DM_VERSION   # Automatically populate created_at, created_on, etc. when those properties are present.
#dependency "dm-types", DM_VERSION        # Provides additional types, including csv, json, yaml.
dependency "dm-validations", DM_VERSION  # Validation framework
dependency "dm-serializer", DM_VERSION # Serialization framework
dependency "dm-paperclip", "2.1.4"     # File attachment plugin
