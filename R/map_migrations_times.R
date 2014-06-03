#!/usr/bin/env Rscript
# Created by Daniele Silvestro on 29/05/2014
# Thanks to Martha Serrano-Serrano and Ruud Scharn
pkload <- function(x)
{
  if (!suppressMessages(require(x,character.only = TRUE)))
  {
    install.packages(x,dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}

pkload("ape")
pkload("phytools")
pkload("geiger")
pkload("optparse")
# 
# library(ape)
# library(phytools)
# library(geiger)
# library(optparse)

####################################################################################
option_list <- list(

    make_option("--r", type="integer", default=100,
        help="Frequency of sampling [default %default]",
        metavar="Freq_of_Sampling"),

    make_option("--s", type="integer", default=60,
        help=("Max run time for 1 stochastic map [default %default]."),
        metavar="Burnin"),

    make_option("--m", default="SYM",
        help=("Model: 'ER','SYM','ARD' [default %default]."),
        metavar="Prnt_freq"),

    make_option("--o", default="migration_plot",
        help=("Name output file (pdf) [default %default]."),
        metavar="Prnt_freq")

    )

parser_object <- OptionParser(usage = "Usage: %prog [Working directory] [SpecieGeoCoder table] [Tree] Options]", 
option_list=option_list, description="")
opt <- parse_args(parser_object, args = commandArgs(trailingOnly = TRUE), positional_arguments=TRUE)

if (length(opt$args) < 3){
   cat("Error message: At least one of the input files is missing has not been specified.\n\n"); print_help(parser_object); quit(status=1)
}

wd=        opt$args[1]     #  "/Users/daniele/Desktop/map_migration_time/"
tbl_file=  opt$args[2]     #  "three_states.txt"   # "SGC_table.txt"  # "CAHighlands_SA.txt"
tree_file= opt$args[3]     #  "1birdtree.nex"
out_file=sprintf("%s.pdf", opt$options$o)
out_table=sprintf("%s.txt", opt$options$o)
n_rep=opt$options$r
map_model=opt$options$m
max_run_time=opt$options$s 

####################################################################################
setwd(wd)
tbl= read.table(tbl_file,header=T,stringsAsFactors=F) # , sep="\t"
area_name=colnames(tbl)
tree <- read.nexus(tree_file)
pdf(file=out_file,width=10, height=7)

####################################################################################
F_calc <- function(res2){
	M_ages=NULL 
	for (i in 1:1000){
		# draw rand uniform numbers
		M_age=runif(n=length(res2[,1]),max=res2$age0,min=res2$age1)
		h1=hist(M_age, breaks=bins,plot=F)
		M_ages= rbind(M_ages,h1$counts)
	}
	x=as.data.frame(M_ages)   #q <- apply(x, 2, summary)
	m <- apply(x, 2, min)     #m = q[2,]
	M <- apply(x, 2, max)     #M = q[5,]
	a <- apply(x, 2, mean)    #a = q[3,]
	age=-h1$mids 
	return(as.data.frame(cbind(m,M,a,age)))
}

F_plot <- function(L,title="Migrations through time"){
	plot(L$age,L$a,type = 'n', ylim = c(0, max(L$M)), xlim = c(min(L$age),0), ylab = 'migration events', xlab = 'Ma',main=title)
	polygon(c(L$age, rev(L$age)), c(L$M, rev(L$m)), col = "#E5E4E2", border = NA)
	lines(y=L$a, x=L$age, col = "#504A4B", border = NULL)
}

run_SM <- function(tree, trait,max_run){
	setTimeLimit(cpu = Inf, elapsed = max_run, transient = TRUE)
	map=suppressMessages(make.simmap(tree, trait[,1],pi="estimated",model=map_model))
	return(map)
}

####################################################################################
RES=list()
effective_rep=0
for (replicate in 1:n_rep){
	
	cat("\nreplicate:", replicate,"\t")
	
	# resample widespread taxa (not allowed in SM) to randomly assign one area
	trait=data.frame()
	taxa=vector()
	j=1
	for (i in 1:length(tbl[,1]) ){
		state = which(tbl[i,] == 1)-1 # 
		if (length(state)>0){
			trait[j,1]=state[sample(length(state),1)]
			taxa[j]=tbl[i,1]
			j=j+1	
		}
	}

	rownames(trait)=taxa
	
	if (length(taxa)==0) {stop("\nAll taxa have empty ranges!\n")}
		
	# prune tree to match taxa in the table
	treetrait <-suppressWarnings(treedata(tree,trait))
	tree <- treetrait$phy
	trait <- treetrait$data
	if (length(trait)==0) {stop("\nNo matching taxa!\n")}
	#cat(sprintf("\nfound %s matching taxa\n", length(trait)))
	branchtimes= branching.times(tree)
	bins=0:ceiling(max(branchtimes))

	map=NULL
	sink(file=out_table,type = c("output", "message"))
	if (replicate==1){
		map=run_SM(tree, trait,Inf) #map=make.simmap(tree, trait[,1],pi="estimated",model=map_model)
		}else{
			tryCatch({ # stochastic mapping | stop after max_run_time
				map=run_SM(tree, trait,max_run_time)
			}
				,error = function(e) {NULL}
				)
		}
	sink(file=NULL)
	
	
	if (!is.null(map)){
		# make table migration times
		res=data.frame()
		effective_rep=effective_rep+1
		j=1
		for (i in 1:length(map$maps)){ 
		    y=map$maps[[i]]
		    if (identical(names(y[1]), names(y[length(y)]))==F) {
		    	res[j,1]=i
			res[j,2]=branchtimes[[as.character(tree$edge[i,1])]] 
			if (tree$edge[i,][2]<=length(tree$tip.label)) { 
			      res[j,3]=0   # when branch finish in a tip (at present zero age)
			      } else { 
			      res[j,3]=branchtimes[[as.character(tree$edge[i,2])]]
			      } 
			res[j,4]=names(y[1])
			res[j,5]=names(y[length(y)])
			j = j+1
			} 
		}
		colnames(res)=c("edge", "age0", "age1","from","to")
	
		# calc mean, 95% CI migration events
		RES_temp=list()
		RES_temp[[1]]=F_calc(res)
		i=1
		directions=as.vector("global")
		for (f in 1:max(res$to)){
			for (t in 1:max(res$to)) {
				if  (f != t) {
					i = i+1
					res2=res[res$from==f & res$to==t,]
					RES_temp[[i]]=F_calc(res2)
					directions[i]=sprintf("Migrations through time: %s -> %s",area_name[f+1],area_name[t+1])
					#F_plot(L,)
				}
			}
		}
		# average results over SMs
		if (replicate==1){
			RES=RES_temp
			}else{
				for (i in 1:length(RES)){RES[[i]]=RES[[i]]+ RES_temp[[i]]}
			}		
	}else{cat("Time limit reached!")}
}

cat(sprintf("# Headers: min, max, and average (m, M, a) number of migration events through time (age) averaged over %s stochastic maps.\n", effective_rep),file=out_table)

# make plots/output table
for (i in 1:length(RES)){
	counts=RES[[i]]/effective_rep
	F_plot(counts,directions[i])
	cat(sprintf("# Table %s (%s).\n",i,directions[i]), file=out_table,append = T)
	row.names(counts)=paste0(row.names(counts), sep="_",rep(directions[i], length(counts[,1])))
	if (i==1){
		suppressWarnings(write.table(counts, file=out_table,append = T,sep="\t",row.names=T,col.names=T))
		}else{suppressWarnings(write.table(counts, file=out_table,append = T,sep="\t",row.names=T,col.names=F))}
	
}

suppressMessages((dev.off())
















