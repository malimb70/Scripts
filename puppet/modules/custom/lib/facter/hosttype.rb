# Find the ENV type
ehenv = case Facter.value(:fqdn)
  when /^usnjdev[lwv]/ then "dev"
  when /^usnjqa1[lwv]/ then "qa1"
  when /^usnjqa2[lwv]/ then "qa2"
  when /^usnjqa3[lwv]/ then "qa3"
  when /^usnjstg[lwv]/ then "stage"
  when /^usnj[lw]/ then "prod"
  when /^awse[lw]/ then "prod"
  when /^awsestg[lw]/ then "stage"
  when /^awses[lw]/ then "stage"
  when /^awseqa/ then "qa1"
  when /^awsedev/ then "dev"
  when /^aws[lw]/ then "prod"
  when /^awsstg[lw]/ then "stage"
  when /^awss[lw]/ then "stage"
  when /^awsqa1[lw]/ then "qa1"
  when /^awsqa2[lw]/ then "qa2"
  when /^awsdev[lw]/ then "dev"
  when /^mptstg[lw]/ then "stage"
  when /^mptdev[lw]/ then "dev"
  when /^mptqa1[lw]/ then "qa1"
  when /^mptqa2[lw]/ then "qa2"
  when /^mpt[wl]/ then "prod"
  when /^wtestg[lw]/ then "stage"
  when /^wtedev[lw]/ then "dev"
  when /^wteqa1[lw]/ then "qa1"
  when /^wteqa2[lw]/ then "qa2"
  when /^wteqa3[lw]/ then "qa3"
  when /^wte[wl]/ then "prod"
  else "unknown"
  end

Facter.add("ehenv") do
#  confine :kernel => :linux
  setcode do
    ehenv.to_s
  end
end

ehdc = case Facter.value(:fqdn)
  when /^usnj/ then "sungard"
  when /^aws/ then "amazon"
  when /^mpt/ then "amazon"
  when /^wte/ then "amazon"
  when /^eh/ then "amazon"
  else "unknown"
  end

Facter.add("ehdc") do
  setcode do
    ehdc.to_s
  end
end

