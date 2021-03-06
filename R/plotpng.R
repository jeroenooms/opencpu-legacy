plotpng <- function(fnargs){
	CONTENTTYPE <- "image/png";
	mytempfile <- do.call(doplotpng, fnargs);
	return(list(filename = mytempfile, type = CONTENTTYPE));	
}

doplotpng <- function(`#dofn`, `!width` = 640, `!height` = 480, `!units` = "px", `!pointsize` =12, `!printoutput`= TRUE, ...){
	
	#prepare
	mytempfile <- tempfile();
	png(mytempfile, width=`!width`, height=`!height`, units=`!units`, pointsize=`!pointsize`);
	par("bg" = "white")
	
	# The code below works fine. However, hadley's method results in a smaller 'call' object for the 
	# resulting object.
	#
	# e1 <- new.env(parent = .GlobalEnv)
	# output <- eval(get("#dofn")(...), envir=e1);
	
	#build the function call and evaluate expressions at the very last moment.
	fnargs <- as.list(match.call(expand.dots=F)$...);
	argn <- lapply(names(fnargs), as.name);
	names(argn) <- names(fnargs);
	
	#insert expressions into call
	exprargs <- sapply(fnargs, is.expression);
	if(length(exprargs) > 0){
		expressioncalls <- lapply(fnargs[exprargs], "[[", 1);
		argn[names(fnargs[exprargs])] <- expressioncalls;
	}
	
	#call the new function
	if(is.character(`#dofn`)){
		mycall <- as.call(c(list(parse(text=`#dofn`)[[1]]), argn));
	} else {
		mycall <- as.call(c(list(as.name("FUN")), argn));
		fnargs <- c(fnargs, list("FUN" = `#dofn`));		
	}
	
	output <- eval(mycall, fnargs, globalenv());
	
	if(`!printoutput`){
		void <- capture.output(print(output));
	}
	
	#write output
	dev.off();
	
	#check if something as generated
	if(!file.exists(mytempfile)){
		stop("This call did not generate any plot. Make sure the function/object produces a graph.")	
	}
	
	return(mytempfile)		
}