alert 123

Api.call 'projects/ping'
Api.call 'projects/ping', org_id: 4
Api.silent.call('projects/ping', org_id: 4).done()



