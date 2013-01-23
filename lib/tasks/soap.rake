if defined?(JRUBY_VERSION)

  require 'jbundler/lazy'
  include JBundler::Lazy
  require 'ant'
  ant.taskdef(name: "wsimport", classname: "com.sun.tools.ws.ant.WsImport")

  namespace :odm do
    src_dir = 'ext/java'
    build_dir = "build"
    wsdl = 'config/TMSExtended.wsdl'

    task :clean do
      ant.delete(:includeemptydirs => true, :failonerror => false) do
        fileset(dir: src_dir, includes: "**/*")
        fileset(dir: build_dir, includes: "**/*")
      end
    end

    task :compile => :clean do
      ant.mkdir(dir: build_dir)
      ant.mkdir(dir: src_dir)
      ant.wsimport(wsdl: wsdl,
                   sourcedestdir: src_dir,
                   destdir: build_dir,
                   xadditionalHeaders: true)
      ant.javac(:destdir => build_dir) do
        src { path :location => src_dir }
      end
    end

    desc 'build ODMv2 SOAP JAR'
    task :jar => :compile do
      ant.jar :destfile => "lib/tms_extended.jar", :basedir => build_dir
    end

  end

end