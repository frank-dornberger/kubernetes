resource "newrelic_dashboard" "hello_world" {
  icon     = "dashboard"
  editable = "editable_by_owner"
  title    = "hello_world board (Terraform)"

  widget {
    title         = "no threshold support :'("
    row           = 1
    column        = 1
    width         = 1
    visualization = "billboard"
    nrql          = "SELECT average(duration) FROM PageView WHERE appName = 'hello_world'"
  }

  widget {
    title         = "no gauge support :'("
    row           = 1
    column        = 2
    width         = 1
    visualization = "billboard"
    nrql          = "SELECT 0 as 'no_data'"
  }

  widget {
    title         = "no math support :'("
    row           = 1
    column        = 3
    width         = 1
    visualization = "histogram"
    nrql          = "SELECT histogram(duration*25) FROM PageView WHERE appName = '${var.app_name}' FACET deviceType"
  }

  widget {
    title         = "no linking support :'("
    row           = 2
    column        = 1
    width         = 1
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) from PageView WHERE appName = '${var.app_name}' FACET deviceType"
  }

  widget {
    title         = "Transaction success rate"
    row           = 2
    column        = 2
    width         = 1
    visualization = "line_chart"
    nrql          = "SELECT percentage(count(httpResponseCode), WHERE httpResponseCode = '200') FROM Transaction WHERE appName = '${var.app_name}' TIMESERIES AUTO"
  }

  widget {
    title         = "Users per country"
    row           = 2
    column        = 3
    width         = 1
    visualization = "facet_pie_chart"
    nrql          = "SELECT count(*) from PageView WHERE appName = '${var.app_name}' FACET countryCode"
  }

  widget {
    title         = "Throughput per Browser & Version"
    row           = 3
    column        = 1
    width         = 1
    visualization = "faceted_area_chart"
    nrql          = "SELECT count(*) FROM PageView WHERE appName = '${var.app_name}' FACET userAgentName, userAgentVersion TIMESERIES AUTO "
  }

  widget {
    title         = "${var.app_name} Memory Usage"
    row           = 3
    column        = 2
    width         = 1
    visualization = "faceted_line_chart"
    nrql          = "SELECT average(memoryUsedBytes) as 'MemoryConsumption' FROM K8sContainerSample WHERE podName LIKE '%world%' FACET podName UNTIL 1 minute ago TIMESERIES"
  }

  widget {
    title         = "${var.app_name} Memory Usage - % Used vs Limit"
    row           = 3
    column        = 3
    width         = 1
    visualization = "faceted_line_chart"
    nrql          = "SELECT latest(memoryUsedBytes/memoryLimitBytes) * 100 as '% Memory' FROM K8sContainerSample WHERE podName LIKE '%world%' FACET podName UNTIL 1 minute ago TIMESERIES"
  }

  widget {
    title         = "Throughput per host"
    row           = 4
    column        = 1
    width         = 1
    visualization = "faceted_area_chart"
    nrql          = "SELECT count(*) from Transaction WHERE appName = '${var.app_name}' FACET host TIMESERIES AUTO"
  }

  widget {
    title         = "${var.app_name} CPU Usage"
    row           = 4
    column        = 2
    width         = 1
    visualization = "faceted_line_chart"
    nrql          = "SELECT average(cpuUsedCores) as 'CPUCores' FROM K8sContainerSample WHERE podName LIKE '%world%' FACET podName UNTIL 1 minute ago TIMESERIES"
  }

  widget {
    title         = "${var.app_name} CPU Usage - % Used vs Limit"
    row           = 4
    column        = 3
    width         = 1
    visualization = "faceted_line_chart"
    nrql          = "SELECT latest(cpuUsedCores/cpuLimitCores) * 100 as '% CPU' FROM K8sContainerSample WHERE podName LIKE '%world%' FACET podName UNTIL 1 minute ago TIMESERIES"
  }
}
