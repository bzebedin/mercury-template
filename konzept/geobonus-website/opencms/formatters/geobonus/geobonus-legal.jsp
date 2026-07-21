<%@page pageEncoding="UTF-8" buffer="none" session="false" trimDirectiveWhitespaces="true"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m"   tagdir="/WEB-INF/tags/mercury" %>

<m:init-messages>
<cms:formatter var="content" val="value">
<m:setting-defaults>

<c:set var="ade" value="${cms.isEditMode}" />

<article class="element type-gb-legal${setCssWrapperAll}"><%----%>
    <header class="legal-head"><div class="wrap"><%----%>
        <c:if test="${value.Eyebrow.isSet}"><span class="eyebrow"><span class="dot"></span>${value.Eyebrow}</span></c:if><%----%>
        <h1 ${ade ? content.rdfa.Title : ''}>${value.Title}</h1><%----%>
        <c:if test="${value.Subtitle.isSet}"><p class="legal-sub">${value.Subtitle}</p></c:if><%----%>
        <hr class="legal-rule"><%----%>
    </div></header><%----%>

    <div class="legal-body"><div class="wrap"><div class="legal-doc"><%----%>
        <c:if test="${value.Intro.isSet}"><div class="legal-intro">${value.Intro}</div></c:if><%----%>
        <c:forEach var="sec" items="${content.valueList.Section}"><%----%>
            <section class="legal-sec"><%----%>
                <h2 class="legal-h2">${sec.value.Heading}</h2><%----%>
                <div class="legal-sec-body">${sec.value.Body}</div><%----%>
            </section><%----%>
        </c:forEach><%----%>
    </div></div></div><%----%>
</article><%----%>

</m:setting-defaults>
</cms:formatter>
</m:init-messages>
