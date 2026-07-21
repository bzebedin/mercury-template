<%@page pageEncoding="UTF-8" buffer="none" session="false" trimDirectiveWhitespaces="true"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m"   tagdir="/WEB-INF/tags/mercury" %>

<m:init-messages>
<cms:formatter var="content" val="value">
<m:setting-defaults>

<nav class="nav-group" aria-label="Hauptnavigation"><%----%>
    <c:forEach var="entry" items="${content.valueList.Entry}"><%----%>
        <m:link link="${entry}" css="nav-link">${entry.value.Text}</m:link><%----%>
    </c:forEach><%----%>
</nav><%----%>

</m:setting-defaults>
</cms:formatter>
</m:init-messages>
