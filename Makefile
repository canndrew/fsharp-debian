include $(topsrcdir)mono/config.make

.PHONY: build build-proto

# Make the proto using the bootstrap, then make the final compiler using the proto
# We call MAKE sequentially because we don't want build-final to explicitly depend on build-proto,
# as that causes a complete recompilation of both proto and final everytime you touch the
# compiler sources.
all:
	@echo -----------
	@echo prefix=$(prefix)
	@echo topdir=$(topdir)
	@echo monodir=$(monodir)
	@echo monolibdir=$(monolibdir)
	@echo monobindir=$(monobindir)
	@echo -----------
	$(MAKE) build-proto
	$(MAKE) build

build-proto:
	MONO_ENV_OPTIONS=$(monoopts) $(XBUILD) /p:Configuration=Proto /p:TargetFramework=$(TargetFramework) src/fsharp/FSharp.Build-proto/FSharp.Build-proto.fsproj
	MONO_ENV_OPTIONS=$(monoopts) $(XBUILD) /p:Configuration=Proto /p:TargetFramework=$(TargetFramework) src/fsharp/Fsc-proto/Fsc-proto.fsproj

# The main targets
build:
	MONO_ENV_OPTIONS=$(monoopts) $(XBUILD) /p:Configuration=$(Configuration) /p:TargetFramework=net40 src/fsharp/FSharp.Core/FSharp.Core.fsproj
	MONO_ENV_OPTIONS=$(monoopts) $(XBUILD) /p:Configuration=$(Configuration) /p:TargetFramework=net40 src/fsharp/FSharp.Build/FSharp.Build.fsproj
	MONO_ENV_OPTIONS=$(monoopts) $(XBUILD) /p:Configuration=$(Configuration) /p:TargetFramework=net40 src/fsharp/FSharp.Compiler.Private/FSharp.Compiler.Private.fsproj
	MONO_ENV_OPTIONS=$(monoopts) $(XBUILD) /p:Configuration=$(Configuration) /p:TargetFramework=net40 src/fsharp/Fsc/Fsc.fsproj
	MONO_ENV_OPTIONS=$(monoopts) $(XBUILD) /p:Configuration=$(Configuration) /p:TargetFramework=net40 src/fsharp/FSharp.Compiler.Interactive.Settings/FSharp.Compiler.Interactive.Settings.fsproj
	MONO_ENV_OPTIONS=$(monoopts) $(XBUILD) /p:Configuration=$(Configuration) /p:TargetFramework=net40 src/fsharp/FSharp.Compiler.Server.Shared/FSharp.Compiler.Server.Shared.fsproj
	MONO_ENV_OPTIONS=$(monoopts) $(XBUILD) /p:Configuration=$(Configuration) /p:TargetFramework=net40 src/fsharp/fsi/Fsi.fsproj
	MONO_ENV_OPTIONS=$(monoopts) $(XBUILD) /p:Configuration=$(Configuration) /p:TargetFramework=net40 src/fsharp/fsiAnyCpu/FsiAnyCPU.fsproj
	MONO_ENV_OPTIONS=$(monoopts) $(XBUILD) /p:Configuration=$(Configuration) /p:TargetFramework=net40 tests/FSharp.Core.UnitTests/FSharp.Core.Unittests.fsproj



install:
	-rm -fr $(DESTDIR)$(monodir)/fsharp
	-rm -fr $(DESTDIR)$(monodir)/Microsoft\ F#
	-rm -fr $(DESTDIR)$(monodir)/Microsoft\ SDKs/F#
	-rm -fr $(DESTDIR)$(monodir)/xbuild/Microsoft/VisualStudio/v/FSharp
	-rm -fr $(DESTDIR)$(monodir)/xbuild/Microsoft/VisualStudio/v11.0/FSharp
	-rm -fr $(DESTDIR)$(monodir)/xbuild/Microsoft/VisualStudio/v12.0/FSharp
	-rm -fr $(DESTDIR)$(monodir)/xbuild/Microsoft/VisualStudio/v14.0/FSharp
	-rm -fr $(DESTDIR)$(monodir)/xbuild/Microsoft/VisualStudio/v15.0/FSharp
	$(MAKE) -C mono/FSharp.Core TargetFramework=net40 install
	$(MAKE) -C mono/FSharp.Build install
	$(MAKE) -C mono/FSharp.Compiler.Private install
	$(MAKE) -C mono/Fsc install
	$(MAKE) -C mono/FSharp.Compiler.Interactive.Settings install
	$(MAKE) -C mono/FSharp.Compiler.Server.Shared install
	$(MAKE) -C mono/fsi install
	$(MAKE) -C mono/fsiAnyCpu install
	$(MAKE) -C mono/FSharp.Core TargetFramework=net40 FSharpCoreBackVersion=3.0 install
	$(MAKE) -C mono/FSharp.Core TargetFramework=net40 FSharpCoreBackVersion=3.1 install
	$(MAKE) -C mono/FSharp.Core TargetFramework=net40 FSharpCoreBackVersion=4.0 install
	$(MAKE) -C mono/FSharp.Core TargetFramework=net40 FSharpCoreBackVersion=4.1 install
	$(MAKE) -C mono/FSharp.Core TargetFramework=portable47 install
	$(MAKE) -C mono/FSharp.Core TargetFramework=portable7 install
	$(MAKE) -C mono/FSharp.Core TargetFramework=portable78 install
	$(MAKE) -C mono/FSharp.Core TargetFramework=portable259 install
	$(MAKE) -C mono/FSharp.Core TargetFramework=monoandroid10+monotouch10+xamarinios10 install
	$(MAKE) -C mono/FSharp.Core TargetFramework=xamarinmacmobile install
	echo "------------------------------ INSTALLED FILES --------------"
	ls -xlR $(DESTDIR)$(monodir)/fsharp $(DESTDIR)$(monodir)/xbuild $(DESTDIR)$(monodir)/xbuild $(DESTDIR)$(monodir)/Reference\ Assemblies $(DESTDIR)$(monodir)/gac/FSharp* $(DESTDIR)$(monodir)/Microsoft* || true

dist:
	-rm -r fsharp-$(DISTVERSION) fsharp-$(DISTVERSION).tar.bz2
	mkdir -p fsharp-$(DISTVERSION)
	(cd $(topdir) && git archive HEAD |(cd $(builddir)fsharp-$(DISTVERSION) && tar xf -))
	list='$(EXTRA_DIST)'; for s in $$list; do \
		(cp $(topdir)$$s fsharp-$(DISTVERSION)/$$s) \
	done;
	tar cvjf fsharp-$(DISTVERSION).tar.bz2 $(patsubst %,--exclude=%, $(NO_DIST)) fsharp-$(DISTVERSION)
	du -b fsharp-$(DISTVERSION).tar.bz2

